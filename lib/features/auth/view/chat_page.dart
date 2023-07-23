import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            child: Stack(
              children: [
                ListView(),
                Container(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Align(
                    alignment: Alignment.bottomCenter,
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
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
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
                                  onTap: () {
                                    // Add message to the chats collection in both the users.
                                    

                                    // Show the message to both the users.
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
          )
        ],
      ),
    );
  }
}
