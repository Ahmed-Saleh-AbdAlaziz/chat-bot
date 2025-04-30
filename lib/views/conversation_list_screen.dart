import 'package:chat1/models/conversation.dart';
import 'package:chat1/widgets/conversation_list_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/chat_view_model.dart';
import 'chat_screen.dart';

class ConversationListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, viewModel, _) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                "المحادثات",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.teal,
              elevation: 4,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.model_training),
                  onPressed: () =>
                      _showModelSelectionDialog(context, viewModel),
                ),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade50, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  if (viewModel.errorMessage != null)
                    _buildErrorWidget(viewModel.errorMessage!),
                  Expanded(
                    child: viewModel.conversations.isEmpty
                        ? _buildEmptyState()
                        : _buildConversationList(context, viewModel),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showNewConversationDialog(context, viewModel),
              child: Icon(Icons.add),
              backgroundColor: Colors.teal,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Container(
      color: Colors.red.shade100,
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      child: Text(
        errorMessage,
        style: TextStyle(color: Colors.red.shade900),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'لا توجد محادثات بعد',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          Text(
            'اضغط على الزر لإنشاء محادثة جديدة',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationList(BuildContext context, ChatViewModel viewModel) {
    return ListView.builder(
      itemCount: viewModel.conversations.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final conversation = viewModel.conversations[index];
        return ConversationListItem(
          conversation: conversation,
          isSelected: viewModel.currentConversation?.id == conversation.id,
          onTap: () {
            viewModel.setCurrentConversation(conversation.id);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider.value(
                  value: viewModel,
                  child: ChatScreen(),
                ),
              ),
            );
          },
          onRename: () => _showRenameDialog(context, viewModel, conversation),
          onDelete: () =>
              _showDeleteConfirmation(context, viewModel, conversation),
        );
      },
    );
  }

  void _showModelSelectionDialog(
      BuildContext context, ChatViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختر نموذج الذكاء الاصطناعي'),
        content: viewModel.availableModels.isEmpty
            ? Text('لا توجد نماذج متاحة')
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: viewModel.availableModels.map((model) {
                    return ListTile(
                      title: Text(model.displayName.isNotEmpty
                          ? model.displayName
                          : model.name),
                      onTap: () {
                        viewModel.setModel(model.name);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showNewConversationDialog(
      BuildContext context, ChatViewModel viewModel) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('محادثة جديدة'),
        content: TextField(
          controller: controller,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'أدخل عنوان المحادثة (اختياري)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              viewModel.createNewConversation(controller.text);
              Navigator.pop(context);
            },
            child: Text('إنشاء'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, ChatViewModel viewModel,
      Conversation conversation) {
    final controller = TextEditingController(text: conversation.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إعادة تسمية المحادثة'),
        content: TextField(
          controller: controller,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'أدخل العنوان الجديد',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              viewModel.renameConversation(controller.text);
              Navigator.pop(context);
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ChatViewModel viewModel,
      Conversation conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف المحادثة'),
        content: Text('هل أنت متأكد من حذف "${conversation.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteConversation(conversation.id);
              Navigator.pop(context);
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
