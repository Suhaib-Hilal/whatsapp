import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsappclone/features/chat/model/message.dart';
import 'package:whatsappclone/shared/firestore_db.dart';
import 'package:whatsappclone/shared/user.dart';
import 'package:whatsappclone/theme/color_theme.dart';
import 'package:whatsappclone/utils/abc.dart';

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.toUser.name,
                  style: const TextStyle(
                    color: AppColorsDark.textColor1,
                    fontSize: 16,
                  ),
                ),
                StreamBuilder(
                  stream: FirestoreDatabase.getUserStatus(widget.toUser.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == "Offline") {
                      return const Text("");
                    }

                    return Text(
                      snapshot.data!,
                      style: const TextStyle(
                        color: AppColorsDark.greyColor,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: const [
          Icon(
            Icons.videocam_rounded,
            color: AppColorsDark.textColor1,
            size: 24,
          ),
          SizedBox(width: 20),
          Icon(
            Icons.phone_rounded,
            color: AppColorsDark.textColor1,
            size: 22,
          ),
          SizedBox(width: 20),
          Icon(
            Icons.more_vert_rounded,
            color: AppColorsDark.textColor1,
            size: 24,
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/dark/chat_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  bottom: 20,
                  left: 12,
                  right: 12,
                ),
                child: StreamBuilder(
                  stream: FirestoreDatabase.getChatMessages(
                    widget.fromUser.id,
                    widget.toUser.id,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) print(snapshot.error.toString());
                    if (!snapshot.hasData) return Container();
                    final messages = snapshot.data!;
                    print(messages);
                    return Align(
                      alignment: Alignment.topCenter,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        reverse: true,
                        shrinkWrap: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isOwnMessage =
                              widget.fromUser.id == message.senderId;
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
                              margin: const EdgeInsets.only(bottom: 3),
                              padding: const EdgeInsets.all(8),
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            message.content.length > 40
                                                ? message.content
                                                : message.content + " " * 12,
                                            style: const TextStyle(
                                              color: AppColorsDark.textColor1,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        formattedTimestamp(
                                          message.timestamp,
                                          onlyTime: true,
                                        ),
                                        style: const TextStyle(
                                          color: AppColorsDark.textColor2,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 2),
                                        child: getMessageStatusWidet(
                                            message.status),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
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
                                  fontSize: 18,
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
                              angle: -0.7,
                              child: Container(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: const Icon(
                                  Icons.attach_file,
                                  color: AppColorsDark.iconColor,
                                  size: 26,
                                ),
                              ),
                            ),
                            messageTextController.text.isEmpty
                                ? const SizedBox(width: 20)
                                : const SizedBox(),
                            messageTextController.text.isEmpty
                                ? Container(
                                    padding: const EdgeInsets.all(2),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: AppColorsDark.iconColor,
                                    ),
                                    child: const Icon(
                                      Icons.currency_rupee_rounded,
                                      color: AppColorsDark.appBarColor,
                                      size: 20,
                                    ),
                                  )
                                : const SizedBox(),
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
                                      size: 24,
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
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
                              Icons.mic,
                              color: Colors.white,
                              size: 30,
                            )
                          : GestureDetector(
                              onTap: () async {
                                final msg = messageTextController.text;
                                messageTextController.text = "";
                                setState(() {});

                                final message = Message(
                                  id: const Uuid().v4(),
                                  content: msg,
                                  senderId: widget.fromUser.id,
                                  receiverId: widget.toUser.id,
                                  status: "",
                                  timestamp: Timestamp.now(),
                                );

                                await FirestoreDatabase.sendMessage(message)
                                    .then((value) async {
                                  await FirestoreDatabase.changeMessageStatus(
                                    message,
                                    "SENT",
                                  );
                                }).onError((error, stackTrace) async {
                                  await FirestoreDatabase.changeMessageStatus(
                                    message,
                                    "PENDING",
                                  );
                                });
                              },
                              child: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget getMessageStatusWidet(String status) {
  if (status != "PENDING" && status != "SENT" && status != "") {
    return const Image(
      image: AssetImage("assets/images/SEEN.png"),
      width: 16,
    );
  } else if (status != "PENDING" && status != "") {
    return const Icon(
      Icons.check_rounded,
      size: 16,
      color: AppColorsDark.textColor2,
    );
  }
  return const Icon(
    Icons.punch_clock_rounded,
    size: 16,
    color: AppColorsDark.textColor2,
  );
}
