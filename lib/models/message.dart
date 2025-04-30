import 'package:uuid/uuid.dart';

enum MessageStatus { sending, sent, delivered, read, failed }

class Message {
  final String id;
  final String sender;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;

  Message({
    String? id,
    required this.sender,
    required this.text,
    DateTime? timestamp,
    this.status = MessageStatus.sent,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      sender: json['sender'] ?? '',
      text: json['text'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      status: _statusFromString(json['status']),
    );
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }

  Message copyWith({
    String? sender,
    String? text,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    return Message(
      id: id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}
