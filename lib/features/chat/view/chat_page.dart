import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  List<Widget> _popupMenuItems() {
    return [
      AttachmentOption(
        icon: Icons.edit_document,
        text: "Document",
        color: Colors.purple,
        onTap: () {},
      ),
      AttachmentOption(
          icon: Icons.camera_alt_rounded,
          text: "Camera",
          color: Colors.pink,
          onTap: () async {
            XFile? image = await getSelectedImage("Camera");
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
          }),
      AttachmentOption(
        icon: Icons.photo_rounded,
        text: "Gallery",
        color: const Color.fromARGB(255, 250, 149, 240),
        onTap: () async {
          XFile? image = await getSelectedImage("Gallery");
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
      ),
      AttachmentOption(
        icon: Icons.headphones,
        text: "Audio",
        color: Colors.orange,
        onTap: () {},
      ),
      AttachmentOption(
        icon: Icons.person,
        text: "Contact",
        color: AppColorsDark.blueColor,
        onTap: () {},
      ),
      AttachmentOption(
        icon: Icons.location_on,
        text: "Location",
        color: AppColorsDark.greenColor,
        onTap: () {},
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                      if (snapshot.hasError) {
                        print(snapshot.error.toString());
                      }
                      if (!snapshot.hasData) return Container();

                      final messages = snapshot.data!;

                      return ListView.builder(
                        addAutomaticKeepAlives: true,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        shrinkWrap: true,
                        itemCount: messages.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isOwnMessage =
                              widget.fromUser.id == message.senderId;
                          return Align(
                            key: ValueKey(message.id),
                            alignment: isOwnMessage
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: MessageCard(
                              message: message,
                              ownMessage: isOwnMessage,
                            ),
                          );
                        },
                        findChildIndexCallback: (key) {
                          final id = (key as ValueKey).value;
                          return messages.indexWhere(
                            (message) => message.id == id,
                          );
                        },
                      );
                      // [3, 2, 1]
                      // [4, 3, 2, 1]
                    },
                  )),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  Container(
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
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 60),
                                            child: Dialog(
                                              alignment: Alignment.bottomCenter,
                                              backgroundColor:
                                                  AppColorsDark.backgroundColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              insetPadding: EdgeInsets.only(
                                                left: 12.0,
                                                right: 12.0,
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    (Platform.isIOS
                                                        ? 0.54
                                                        : 0.4),
                                              ),
                                              insetAnimationCurve:
                                                  Curves.easeInOutQuad,
                                              insetAnimationDuration:
                                                  const Duration(
                                                      milliseconds: 500),
                                              elevation: 0,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 32.0,
                                                  vertical: 18.0,
                                                ),
                                                child: GridView.count(
                                                  crossAxisCount: 3,
                                                  shrinkWrap: true,
                                                  children: [
                                                    for (var i = 0;
                                                        i <
                                                            _popupMenuItems()
                                                                .length;
                                                        i++) ...[
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Card(
                                                          color: AppColorsDark
                                                              .backgroundColor,
                                                          elevation: 0,
                                                          child:
                                                              _popupMenuItems()[
                                                                  i],
                                                        ),
                                                      )
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: const Icon(
                                        Icons.attach_file,
                                        color: AppColorsDark.iconColor,
                                        size: 26,
                                      ),
                                    ),
                                  ),
                                ),
                                messageTextController.text.isEmpty
                                    ? const SizedBox(width: 20)
                                    : const SizedBox(),
                                messageTextController.text.isEmpty
                                    ? Container(
                                        padding: const EdgeInsets.all(2),
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
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
                                          XFile? image =
                                              await getSelectedImage("Camera");
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
                                    if (msg.isEmpty) return;

                                    messageTextController.text = "";
                                    setState(() {});

                                    final message = Message(
                                      id: const Uuid().v4(),
                                      attachment: const Attachment(
                                        attachmentType: "",
                                        attachmentValue: "",
                                        fileName: "",
                                        width: 0,
                                        height: 0,
                                      ),
                                      content: msg,
                                      senderId: widget.fromUser.id,
                                      receiverId: widget.toUser.id,
                                      status: "",
                                      timestamp: Timestamp.now(),
                                    );

                                    FirestoreDatabase.sendMessage(message)
                                        .then((value) async {
                                      await FirestoreDatabase
                                          .changeMessageStatus(
                                        message,
                                        "SENT",
                                      );
                                    }).onError((error, stackTrace) async {
                                      print(error);
                                      await FirestoreDatabase
                                          .changeMessageStatus(
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
                  Container(
                    height: MediaQuery.of(context).viewInsets.bottom,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Function() onTap;
  const AttachmentOption({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            text,
            style: const TextStyle(
              color: AppColorsDark.iconColor,
            ),
          ),
        ],
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
  late Future<File?> _doesAttachmentExist = doesAttachmentExist();
  late final Future<DownloadTask> _downloadFuture = download();
  bool isDownloading = false;

  @override
  bool get wantKeepAlive => true;

  Future<File?> doesAttachmentExist() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file =
        File('${directory.path}/${widget.message.attachment.fileName}');
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  Future<DownloadTask> download() async {
    final attachment = widget.message.attachment;
    return await FirebaseStorageUtil.downloadFileFromFirebase(
      attachment.attachmentValue,
      attachment.fileName,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final messageColor = widget.ownMessage
        ? AppColorsDark.outgoingMessageBubbleColor
        : AppColorsDark.incomingMessageBubbleColor;

    final imgWidth = widget.message.attachment.width;
    final imgHeight = widget.message.attachment.height;
    final aspectRatio = imgWidth / imgHeight;
    final maxWidth = MediaQuery.of(context).size.width * 0.8;
    final maxHeight = MediaQuery.of(context).size.height * 0.4;

    double width;
    double height;
    if (imgHeight > imgWidth) {
      height = min(imgHeight, maxHeight);
      width = max(height * aspectRatio, 0.8 * maxWidth);
    } else {
      width = min(imgWidth, maxWidth);
      height = width / aspectRatio;
    }

    final hasAttachment = widget.message.attachment.attachmentValue.isNotEmpty;
    final isImage =
        widget.message.attachment.attachmentType.toLowerCase() == "image";

    return Container(
      constraints: BoxConstraints(
        minWidth: 40,
        maxWidth: maxWidth,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: messageColor,
      ),
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.all(3),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasAttachment) ...[
                if (isImage) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: Center(
                        child: FutureBuilder(
                          future: _doesAttachmentExist,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(
                                color: AppColorsDark.greenColor,
                              );
                            }
                            final file = snapshot.data;
                            if (file != null) {
                              return Image.file(
                                file,
                                width: width,
                                height: height,
                              );
                            }

                            return !isDownloading
                                ? GestureDetector(
                                    onTap: () =>
                                        setState(() => isDownloading = true),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColorsDark.greenColor),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: const EdgeInsets.all(2.5),
                                      child: const Icon(
                                        Icons.download_rounded,
                                        color: AppColorsDark.greenColor,
                                      ),
                                    ),
                                  )
                                : FutureBuilder(
                                    future: _downloadFuture,
                                    builder: (context, snap) {
                                      if (!snap.hasData) {
                                        return const CircularProgressIndicator();
                                      }

                                      final downloadTask = snap.data!;
                                      return FutureBuilder(
                                        future: () async {
                                          return await downloadTask;
                                        }(),
                                        builder: (context, snap) {
                                          if (!snap.hasData) {
                                            return const CircularProgressIndicator();
                                          }

                                          WidgetsBinding.instance
                                              .addPostFrameCallback(
                                            (_) {
                                              setState(
                                                () {
                                                  _doesAttachmentExist =
                                                      doesAttachmentExist();
                                                  isDownloading = false;
                                                },
                                              );
                                            },
                                          );

                                          return const CircularProgressIndicator();
                                        },
                                      );
                                    },
                                  );
                          },
                        ),
                      ),
                    ),
                  )
                ]
              ],
              if (hasAttachment && widget.message.content.isNotEmpty ||
                  widget.message.content.isNotEmpty) ...[
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
                          widget.message.content.trim().length > 40
                              ? widget.message.content.trim()
                              : widget.ownMessage
                                  ? widget.message.content.trim() + " " * 14
                                  : widget.message.content.trim() + " " * 10,
                          style: const TextStyle(
                            color: AppColorsDark.textColor1,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
          Container(
            margin: hasAttachment && widget.message.content.isEmpty ||
                    widget.message.content.isEmpty
                ? const EdgeInsets.only(bottom: 8)
                : null,
            decoration: hasAttachment && widget.message.content.isEmpty ||
                    widget.message.content.isEmpty
                ? const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 28, 31, 32),
                        blurRadius: 22,
                        spreadRadius: 4,
                      )
                    ],
                  )
                : null,
            child: Row(
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
                              final imageFile = File(widget.selectedImg.path);
                              final fileName = imageFile.path.split("/").last;
                              final Directory directory =
                                  await getApplicationDocumentsDirectory();
                              final path = '${directory.path}/$fileName';
                              await imageFile.copy(path);

                              final url = await FirebaseStorageUtil.uploadFile(
                                "attachments/$id",
                                imageFile,
                              );
                              final dimensions =
                                  await getImageDimensions(imageFile);

                              final message = Message(
                                id: id,
                                attachment: Attachment(
                                  attachmentType: "Image",
                                  attachmentValue: url,
                                  fileName: fileName,
                                  width: dimensions.$1,
                                  height: dimensions.$2,
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
