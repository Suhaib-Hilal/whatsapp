import 'package:whatsappclone/shared/user.dart';

class Message {
  final String content;
  final User owner;

  const Message({
    required this.content,
    required this.owner,
  });

   Map<String, Object> toMap(Message message) {
    return {
      "content": message.content,
      "owner": message.owner,
    };
  }
}
