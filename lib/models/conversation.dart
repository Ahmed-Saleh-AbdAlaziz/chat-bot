import 'package:uuid/uuid.dart';

import 'message.dart';

class Conversation {
  final String id;
  final String title;
  final List<Message> messages;
  final DateTime lastUpdated;

  Conversation({
    String? id,
    required this.title,
    List<Message>? messages,
    DateTime? lastUpdated,
  })  : id = id ?? const Uuid().v4(),
        messages = messages ?? [],
        lastUpdated = lastUpdated ?? DateTime.now();

  Conversation addMessage(Message message) {
    final updatedMessages = List<Message>.from(messages)..add(message);
    return Conversation(
      id: id,
      title: title,
      messages: updatedMessages,
      lastUpdated: DateTime.now(),
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      title: json['title'] ?? 'محادثة جديدة',
      messages: (json['messages'] as List?)
              ?.map((msg) => Message.fromJson(msg))
              .toList() ??
          [],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  Conversation copyWith({
    String? title,
    List<Message>? messages,
    DateTime? lastUpdated,
  }) {
    return Conversation(
      id: id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
