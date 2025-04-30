import 'package:flutter/material.dart';

import '../../models/conversation.dart';

class ConversationListItem extends StatelessWidget {
  final Conversation conversation;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const ConversationListItem({
    required this.conversation,
    required this.isSelected,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.teal.shade100,
      title: Text(
        conversation.title,
        style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      ),
      subtitle: Text(
        conversation.lastUpdated.toString().substring(0, 16),
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'rename')
            onRename();
          else if (value == 'delete') onDelete();
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: 'rename', child: Text('إعادة تسمية')),
          PopupMenuItem(value: 'delete', child: Text('حذف')),
        ],
      ),
      onTap: onTap,
    );
  }
}
