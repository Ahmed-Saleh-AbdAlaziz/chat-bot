import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/conversation.dart';
import '../models/message.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chat_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE conversations(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        last_updated TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE messages(
        id TEXT PRIMARY KEY,
        conversation_id TEXT NOT NULL,
        sender TEXT NOT NULL,
        text TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (conversation_id) REFERENCES conversations (id) 
        ON DELETE CASCADE
      )
    ''');
  }

  // Conversation operations
  Future<String> insertConversation(Conversation conversation) async {
    Database db = await instance.database;
    await db.insert(
      'conversations',
      {
        'id': conversation.id,
        'title': conversation.title,
        'last_updated': conversation.lastUpdated.toIso8601String()
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return conversation.id;
  }

  Future<List<Conversation>> getConversations() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conversations',
      orderBy: 'last_updated DESC',
    );

    return List.generate(maps.length, (i) {
      return Conversation(
        id: maps[i]['id'],
        title: maps[i]['title'],
        lastUpdated: DateTime.parse(maps[i]['last_updated']),
      );
    });
  }

  Future<int> updateConversation(Conversation conversation) async {
    Database db = await instance.database;
    return await db.update(
      'conversations',
      {
        'title': conversation.title,
        'last_updated': conversation.lastUpdated.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [conversation.id],
    );
  }

  Future<int> deleteConversation(String id) async {
    Database db = await instance.database;
    return await db.delete(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Message operations
  Future<void> insertMessage(Message message, String conversationId) async {
    Database db = await instance.database;
    await db.insert(
      'messages',
      {
        'id': message.id,
        'conversation_id': conversationId,
        'sender': message.sender,
        'text': message.text,
        'timestamp': message.timestamp.toIso8601String(),
        'status': message.status.toString().split('.').last,
      },
    );

    await db.update(
      'conversations',
      {'last_updated': message.timestamp.toIso8601String()},
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  Future<List<Message>> getMessages(String conversationId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp ASC',
    );

    return List.generate(maps.length, (i) {
      return Message(
        id: maps[i]['id'],
        sender: maps[i]['sender'],
        text: maps[i]['text'],
        timestamp: DateTime.parse(maps[i]['timestamp']),
        status: _statusFromString(maps[i]['status']),
      );
    });
  }

  static MessageStatus _statusFromString(String? statusStr) {
    if (statusStr == null) return MessageStatus.sent;
    try {
      return MessageStatus.values.firstWhere(
        (e) => e.toString().split('.').last == statusStr,
        orElse: () => MessageStatus.sent,
      );
    } catch (_) {
      return MessageStatus.sent;
    }
  }

  Future<int> deleteMessages(String conversationId) async {
    Database db = await instance.database;
    return await db.delete(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
    );
  }
}
