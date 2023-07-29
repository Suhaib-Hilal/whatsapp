import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String content;
  final String senderId;
  final String receiverId;
  final String status;
  final Timestamp timestamp;

  const Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.timestamp,
  });

  Map<String, Object> toMap() {
    return {
      "id": id,
      "content": content,
      "senderId": senderId,
      "receiverId": receiverId,
      "status": status,
      "timestamp": timestamp,
    };
  }

  factory Message.fromMap(Map<String, dynamic> msgData) {
    return Message(
      id: msgData["id"],
      content: msgData["content"],
      senderId: msgData["senderId"],
      receiverId: msgData["receiverId"],
      status: msgData["status"],
      timestamp: msgData["timestamp"],
    );
  }
}
