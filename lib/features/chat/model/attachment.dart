import 'package:cloud_firestore/cloud_firestore.dart';

class Attachment {
  final String attachmentType;
  final String attachmentValue;
  final String fileName;
  final double width;
  final double height;

  const Attachment({
    required this.attachmentType,
    required this.attachmentValue,
    required this.fileName,
    required this.width,
    required this.height,
  });

  Map<String, Object?> toMap() {
    return {
      "attachmentType": attachmentType,
      "attachmentValue": attachmentValue,
      "fileName": fileName,
      "width": width,
      "height": height,
    };
  }

  factory Attachment.fromMap(Map<String, dynamic> msgData) {
    return Attachment(
      attachmentType: msgData["attachmentType"],
      attachmentValue: msgData["attachmentValue"],
      fileName: msgData["fileName"],
      width: msgData["width"] ?? 0,
      height: msgData["height"] ?? 0,
    );
  }
}

class Message {
  final String id;
  final Attachment attachment;
  final String content;
  final String senderId;
  final String receiverId;
  final String status;
  final Timestamp timestamp;

  const Message({
    required this.id,
    required this.attachment,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.timestamp,
  });

  Map<String, Object> toMap() {
    return {
      "id": id,
      "attachment": attachment.toMap(),
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
      attachment: Attachment.fromMap(msgData["attachment"]),
      content: msgData["content"],
      senderId: msgData["senderId"],
      receiverId: msgData["receiverId"],
      status: msgData["status"],
      timestamp: msgData["timestamp"],
    );
  }
}
