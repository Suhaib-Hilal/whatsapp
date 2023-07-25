import 'package:whatsappclone/features/chat/model/message.dart';
import 'package:whatsappclone/shared/user.dart';

class RecentChat {
  final User author;
  final Message lastMsg;
  const RecentChat({required this.author, required this.lastMsg});

  factory RecentChat.fromMap(Map<String, dynamic> chatData) {
    return RecentChat(
      author: chatData["author"],
      lastMsg: chatData["lastMsg"],
    );
  }
}
