import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/api_config.dart';
import 'services/database_helper.dart';
import 'viewmodels/chat_view_model.dart';
import 'views/conversation_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await DatabaseHelper.instance.database;
  runApp(ChatBotApp());
}

class ChatBotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Cairo',
      ),
      home: ChangeNotifierProvider(
        create: (_) => ChatViewModel(apiKey: Config.apiKey),
        child: ConversationListScreen(),
      ),
    );
  }
}
