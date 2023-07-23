import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsappclone/features/chat/model/message.dart';
import 'package:whatsappclone/shared/firestore_db.dart';
import 'package:whatsappclone/shared/user.dart';
import 'package:whatsappclone/theme/color_theme.dart';

class ChatPage extends StatefulWidget {
  final User fromUser;
  final User toUser;
  const ChatPage({super.key, required this.fromUser, required this.toUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageTextController = TextEditingController(text: "");
  int maxLines = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsDark.backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: AppColorsDark.appBarColor,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColorsDark.backgroundColor,
        ),
        backgroundColor: AppColorsDark.appBarColor,
        elevation: 0,
        leadingWidth: 20,
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColorsDark.dividerColor,
              foregroundImage: widget.toUser.avatarUrl.isNotEmpty
                  ? NetworkImage(widget.toUser.avatarUrl)
                  : null,
              child: widget.toUser.avatarUrl.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              widget.toUser.name,
              style: const TextStyle(
                color: AppColorsDark.textColor1,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: const [
          Icon(
            Icons.video_call_rounded,
            color: AppColorsDark.textColor1,
            size: 30,
          ),
          SizedBox(width: 20),
          Icon(
            Icons.phone_rounded,
            color: AppColorsDark.textColor1,
            size: 26,
          ),
          SizedBox(width: 20),
          Icon(
            Icons.more_vert_rounded,
            color: AppColorsDark.textColor1,
            size: 30,
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/dark/chat_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  bottom: 60,
                  left: 12,
                  right: 12,
                ),
                child: StreamBuilder(
                  stream: FirestoreDatabase.getChatMessages(
                    widget.fromUser.id,
                    widget.toUser.id,
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Container();
                    final messages = snapshot.data!;
                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final isOwnMessage =
                            widget.fromUser.id == messages[index].senderId;
                        return Align(
                          alignment: isOwnMessage
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              minWidth: 40,
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.80,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              color: isOwnMessage
                                  ? AppColorsDark.outgoingMessageBubbleColor
                                  : AppColorsDark.incomingMessageBubbleColor,
                            ),
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            child: Text(messages[index].content),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: AppColorsDark.appBarColor,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: const Icon(
                                    Icons.emoji_emotions,
                                    color: AppColorsDark.iconColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: TextField(
                                    onChanged: (value) => setState(() {}),
                                    minLines: 1,
                                    maxLines: 999,
                                    controller: messageTextController,
                                    cursorColor: AppColorsDark.greenColor,
                                    style: const TextStyle(
                                      color: AppColorsDark.textColor1,
                                      fontSize: 16,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: "Message",
                                      hintStyle: TextStyle(
                                        color: AppColorsDark.greyColor,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                Transform.rotate(
                                  angle: 100,
                                  child: Container(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: const Icon(
                                      Icons.attach_file_rounded,
                                      color: AppColorsDark.iconColor,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                messageTextController.text.isEmpty
                                    ? const SizedBox(width: 20)
                                    : const SizedBox(),
                                messageTextController.text.isEmpty
                                    ? Container(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_rounded,
                                          color: AppColorsDark.iconColor,
                                          size: 28,
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            )),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColorsDark.greenColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: messageTextController.text.isEmpty
                            ? const Icon(
                                Icons.mic_rounded,
                                color: Colors.white,
                                size: 30,
                              )
                            : GestureDetector(
                                onTap: () async {
                                  final msg = messageTextController.text;
                                  messageTextController.text = "";

                                  await FirestoreDatabase.addMessage(
                                    Message(
                                      id: const Uuid().v4(),
                                      content: msg,
                                      senderId: widget.fromUser.id,
                                      receiverId: widget.toUser.id,
                                      timestamp: Timestamp.now(),
                                    ),
                                  );
                                },
                                child: const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
