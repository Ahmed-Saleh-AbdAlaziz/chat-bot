import 'package:chat1/models/message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/chat_view_model.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, viewModel, _) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: Text(viewModel.currentConversation?.title ?? 'محادثة'),
              backgroundColor: Colors.teal,
            ),
            body: Column(
              children: [
                Expanded(
                  child: viewModel.messages.isEmpty
                      ? Center(child: Text('لا توجد رسائل بعد'))
                      : _buildMessagesList(viewModel.messages),
                ),
                if (viewModel.isLoading) _buildLoadingIndicator(),
                _buildMessageInput(context, viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessagesList(List<Message> messages) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUser = message.sender == 'user';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? Colors.teal.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.text,
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildMessageInput(BuildContext context, ChatViewModel viewModel) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.teal),
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                viewModel.sendMessage(_controller.text);
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
