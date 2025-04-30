import 'package:flutter/material.dart';

import '../models/ai_model.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class ChatViewModel extends ChangeNotifier {
  final ApiService _apiService;
  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
  bool _isLoading = false;
  List<AIModel> _availableModels = [];
  String _currentModelName = 'gemini-1.5-pro';
  String? _errorMessage;

  ChatViewModel({required String apiKey})
      : _apiService = ApiService(apiKey: apiKey) {
    _loadModels();
    _loadConversations();
  }

  // Getters
  List<Conversation> get conversations => _conversations;

  Conversation? get currentConversation => _currentConversation;

  List<Message> get messages => _currentConversation?.messages ?? [];

  bool get isLoading => _isLoading;

  List<AIModel> get availableModels => _availableModels;

  String get currentModelName => _currentModelName;

  String? get errorMessage => _errorMessage;

  // Private methods
  Future<void> _loadModels() async {
    try {
      _availableModels = await _apiService.fetchModels();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading models: $e');
      _errorMessage = 'Failed to load models: $e';
      notifyListeners();
    }
  }

  Future<void> _loadConversations() async {
    try {
      _conversations = await DatabaseHelper.instance.getConversations();
      if (_conversations.isNotEmpty) {
        await setCurrentConversation(_conversations.first.id);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      _errorMessage = 'Failed to load conversations: $e';
      notifyListeners();
    }
  }

  // Public methods
  Future<void> createNewConversation(String title) async {
    final newConversation = Conversation(
      title: title.isEmpty ? 'New Conversation' : title,
    );

    try {
      await DatabaseHelper.instance.insertConversation(newConversation);
      _conversations.insert(0, newConversation);
      _currentConversation = newConversation;
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating conversation: $e');
      _errorMessage = 'Failed to create conversation: $e';
      notifyListeners();
    }
  }

  Future<void> setCurrentConversation(String conversationId) async {
    try {
      final conversation = _conversations.firstWhere(
        (conv) => conv.id == conversationId,
        orElse: () => throw Exception('Conversation not found'),
      );
      final messages =
          await DatabaseHelper.instance.getMessages(conversationId);
      _currentConversation = conversation.copyWith(messages: messages);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting current conversation: $e');
      _errorMessage = 'Failed to load conversation: $e';
      notifyListeners();
    }
  }

  Future<void> renameConversation(String newTitle) async {
    if (_currentConversation == null) return;

    try {
      final updated = _currentConversation!.copyWith(
        title: newTitle.isEmpty ? 'Untitled Conversation' : newTitle,
        lastUpdated: DateTime.now(),
      );

      await DatabaseHelper.instance.updateConversation(updated);
      final index =
          _conversations.indexWhere((c) => c.id == _currentConversation!.id);
      if (index >= 0) {
        _conversations[index] = updated;
      }
      _currentConversation = updated;
      notifyListeners();
    } catch (e) {
      debugPrint('Error renaming conversation: $e');
      _errorMessage = 'Failed to rename conversation: $e';
      notifyListeners();
    }
  }

  Future<void> deleteConversation(String id) async {
    try {
      await DatabaseHelper.instance.deleteConversation(id);
      _conversations.removeWhere((conv) => conv.id == id);

      if (_currentConversation?.id == id) {
        _currentConversation =
            _conversations.isNotEmpty ? _conversations.first : null;
        if (_currentConversation != null) {
          final messages = await DatabaseHelper.instance
              .getMessages(_currentConversation!.id);
          _currentConversation =
              _currentConversation!.copyWith(messages: messages);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting conversation: $e');
      _errorMessage = 'Failed to delete conversation: $e';
      notifyListeners();
    }
  }

  void setModel(String modelName) {
    _currentModelName = modelName;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _currentConversation == null) return;
    _errorMessage = null;

    final userMessage = Message(
      sender: 'user',
      text: text,
      status: MessageStatus.sent,
    );

    try {
      await DatabaseHelper.instance
          .insertMessage(userMessage, _currentConversation!.id);
      final updatedMessages = List<Message>.from(_currentConversation!.messages)
        ..add(userMessage);
      _currentConversation = _currentConversation!.copyWith(
        messages: updatedMessages,
        lastUpdated: DateTime.now(),
      );

      final convIndex =
          _conversations.indexWhere((c) => c.id == _currentConversation!.id);
      if (convIndex >= 0) {
        _conversations[convIndex] =
            _conversations[convIndex].copyWith(lastUpdated: DateTime.now());
        _conversations.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
      }

      notifyListeners();
      _isLoading = true;
      notifyListeners();

      final botReplyText = await _apiService.generateContent(
        message: text,
        modelName: _currentModelName,
      );

      final botMessage = Message(
        sender: 'bot',
        text: botReplyText,
        status: MessageStatus.delivered,
      );

      await DatabaseHelper.instance
          .insertMessage(botMessage, _currentConversation!.id);
      updatedMessages.add(botMessage);
      _currentConversation = _currentConversation!.copyWith(
        messages: updatedMessages,
        lastUpdated: DateTime.now(),
      );

      if (convIndex >= 0) {
        _conversations[convIndex] =
            _conversations[convIndex].copyWith(lastUpdated: DateTime.now());
        _conversations.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      final errorMessage = Message(
        sender: 'bot',
        text: 'Connection error. Please try again.',
        status: MessageStatus.failed,
      );

      await DatabaseHelper.instance
          .insertMessage(errorMessage, _currentConversation!.id);
      final errorUpdatedMessages =
          List<Message>.from(_currentConversation!.messages)..add(errorMessage);
      _currentConversation = _currentConversation!.copyWith(
        messages: errorUpdatedMessages,
        lastUpdated: DateTime.now(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCurrentConversation() async {
    if (_currentConversation == null) return;

    try {
      await DatabaseHelper.instance.deleteMessages(_currentConversation!.id);
      _currentConversation = _currentConversation!.copyWith(
        messages: <Message>[],
        lastUpdated: DateTime.now(),
      );

      final convIndex =
          _conversations.indexWhere((c) => c.id == _currentConversation!.id);
      if (convIndex >= 0) {
        _conversations[convIndex] =
            _conversations[convIndex].copyWith(lastUpdated: DateTime.now());
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing messages: $e');
      _errorMessage = 'Failed to clear messages: $e';
      notifyListeners();
    }
  }
}
