import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsappclone/features/chat/model/attachment.dart';
import 'package:whatsappclone/shared/firebase_storage.dart';
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
                      return const SizedBox();
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
                    return Align(
                      alignment: Alignment.topCenter,
                      child: ListView.builder(
                        addAutomaticKeepAlives: true,
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
                            child: MessageCard(
                              message: message,
                              ownMessage: isOwnMessage,
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
                                ? GestureDetector(
                                    onTap: () async {
                                      XFile? image = await getSelectedImage();
                                      if (image == null) {
                                        return;
                                      }
                                      if (!mounted) return;
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: ((context) {
                                            return SelectedImagePage(
                                              selectedImg: image,
                                              fromUser: widget.fromUser,
                                              toUser: widget.toUser,
                                            );
                                          }),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        color: AppColorsDark.iconColor,
                                        size: 24,
                                      ),
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
                                  attachment: const Attachment(
                                    attachmentType: "",
                                    attachmentValue: "",
                                  ),
                                  content: msg,
                                  senderId: widget.fromUser.id,
                                  receiverId: widget.toUser.id,
                                  status: "",
                                  timestamp: Timestamp.now(),
                                );

                                FirestoreDatabase.sendMessage(message)
                                    .then((value) async {
                                  await FirestoreDatabase.changeMessageStatus(
                                    message,
                                    "SENT",
                                  );
                                }).onError((error, stackTrace) async {
                                  print(error);
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

class MessageCard extends StatefulWidget {
  final Message message;
  final bool ownMessage;
  const MessageCard(
      {super.key, required this.message, required this.ownMessage});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final messageColor = widget.ownMessage
        ? AppColorsDark.outgoingMessageBubbleColor
        : AppColorsDark.incomingMessageBubbleColor;

    return Container(
      constraints: BoxConstraints(
        minWidth: 40,
        maxWidth: MediaQuery.of(context).size.width * 0.80,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: messageColor,
      ),
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.all(4),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.message.attachment.attachmentValue.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: widget.message.attachment.attachmentValue,
                  ),
                )
              ],
              Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  top: 4,
                  bottom: 4,
                  right: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        widget.message.content.length > 40
                            ? widget.message.content
                            : widget.ownMessage
                                ? widget.message.content + " " * 14
                                : widget.message.content + " " * 10,
                        style: const TextStyle(
                          color: AppColorsDark.textColor1,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formattedTimestamp(
                  widget.message.timestamp,
                  onlyTime: true,
                ),
                style: const TextStyle(
                  color: AppColorsDark.textColor2,
                  fontSize: 12,
                ),
              ),
              widget.ownMessage
                  ? Container(
                      margin: const EdgeInsets.only(
                        left: 4,
                      ),
                      child: getMessageStatusWidet(
                        widget.message.status,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ],
      ),
    );
  }
}

class SelectedImagePage extends StatefulWidget {
  final XFile selectedImg;
  final User fromUser;
  final User toUser;
  const SelectedImagePage({
    super.key,
    required this.selectedImg,
    required this.fromUser,
    required this.toUser,
  });

  @override
  State<SelectedImagePage> createState() => _SelectedImagePageState();
}

class _SelectedImagePageState extends State<SelectedImagePage> {
  TextEditingController captionTextController = TextEditingController(
    text: "",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Container(
        padding: const EdgeInsets.only(top: 50),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(
              File(widget.selectedImg.path),
            ),
            fit: BoxFit.fitWidth,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Align(
              alignment: Alignment.topCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Opacity(
                      opacity: 0.8,
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColorsDark.backgroundColor,
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Opacity(
                        opacity: 0.8,
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColorsDark.backgroundColor,
                          child: Icon(
                            Icons.crop_rotate_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Opacity(
                        opacity: 0.8,
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColorsDark.backgroundColor,
                          child: Icon(
                            Icons.sticky_note_2_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Opacity(
                        opacity: 0.8,
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColorsDark.backgroundColor,
                          child: Text(
                            "T",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Opacity(
                        opacity: 0.8,
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColorsDark.backgroundColor,
                          child: Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                child: Column(
                  children: [
                    Row(
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
                                    Icons.add_photo_alternate_rounded,
                                    color: AppColorsDark.textColor1,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: TextField(
                                    minLines: 1,
                                    maxLines: 999,
                                    controller: captionTextController,
                                    cursorColor: AppColorsDark.greenColor,
                                    style: const TextStyle(
                                      color: AppColorsDark.textColor1,
                                      fontSize: 18,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: "Add a caption...",
                                      hintStyle: TextStyle(
                                        color: AppColorsDark.textColor2,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      color: AppColorsDark.backgroundColor.withOpacity(0.3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColorsDark.appBarColor,
                            ),
                            child: Text(widget.toUser.name),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final id = const Uuid().v4();
                              final url = await FirebaseStorageUtil.uploadFile(
                                "attachments/$id",
                                File(widget.selectedImg.path),
                              );

                              final message = Message(
                                id: id,
                                attachment: Attachment(
                                  attachmentType: "Image",
                                  attachmentValue: url,
                                ),
                                content: captionTextController.text,
                                senderId: widget.fromUser.id,
                                receiverId: widget.toUser.id,
                                status: "",
                                timestamp: Timestamp.now(),
                              );

                              FirestoreDatabase.sendMessage(message)
                                  .then((value) async {
                                await FirestoreDatabase.changeMessageStatus(
                                  message,
                                  "SENT",
                                );
                              }).onError((error, stackTrace) async {
                                print(error);
                                await FirestoreDatabase.changeMessageStatus(
                                  message,
                                  "PENDING",
                                );
                              });
                              if (!mounted) return;
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColorsDark.greenColor,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
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
    return const Image(
      image: AssetImage("assets/images/SENT.png"),
      width: 16,
      color: AppColorsDark.textColor1,
    );
  }
  return const Image(
    image: AssetImage("assets/images/PENDING.png"),
    width: 16,
    color: AppColorsDark.textColor1,
  );
}
