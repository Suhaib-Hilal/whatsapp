import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsappclone/shared/firebase_storage.dart';
import 'package:whatsappclone/shared/firestore_db.dart';
import 'package:whatsappclone/shared/user.dart';
import 'package:whatsappclone/utils/abc.dart';
import '../../../theme/color_theme.dart';
import '../model/phone_number.dart';
import '../../home/view/home_page.dart';

class UserProfilePage extends StatefulWidget {
  final PhoneNumber phone;

  const UserProfilePage({super.key, required this.phone});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  File? selectedImage;
  late final TextEditingController usernameController;

  @override
  void initState() {
    usernameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsDark.backgroundColor,
      appBar: AppBar(
        title: const Center(child: Text("Profile info")),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: AppColorsDark.appBarColor,
            statusBarIconBrightness: Brightness.light),
        backgroundColor: AppColorsDark.appBarColor,
        elevation: 0,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  child: Column(
                    children: [
                      const Text(
                        "Please provide your name and an optional profile photo",
                        style: TextStyle(
                          color: AppColorsDark.textColor1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColorsDark.dividerColor,
                          foregroundImage: selectedImage != null
                              ? FileImage(selectedImage!)
                              : null,
                          child: selectedImage == null
                              ? const Icon(Icons.add_a_photo)
                              : null,
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext builder) {
                              return Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height / 4.8,
                                  padding: const EdgeInsets.all(20),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(4),
                                    ),
                                    color: AppColorsDark.appBarColor,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Profile Photo",
                                            style: TextStyle(
                                              color: AppColorsDark.textColor1,
                                              fontSize: 20,
                                              decoration: TextDecoration.none,
                                              fontFamily:
                                                  String.fromEnvironment(
                                                      "Consolas"),
                                            ),
                                          ),
                                          GestureDetector(
                                            child: const Icon(
                                              Icons.delete,
                                              color: AppColorsDark.iconColor,
                                            ),
                                            onTap: () {
                                              setState(
                                                  () => selectedImage = null);
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          PhotoOption(
                                            icon: const Icon(
                                              Icons.camera_alt,
                                              color: AppColorsDark.greenColor,
                                            ),
                                            text: "Camera",
                                            callback: (file) {
                                              setState(() {
                                                selectedImage = file;
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          PhotoOption(
                                            icon: const Icon(
                                              Icons.photo,
                                              color: AppColorsDark.greenColor,
                                            ),
                                            text: "Gallery",
                                            callback: (file) {
                                              setState(
                                                  () => selectedImage = file);
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                style: const TextStyle(
                                  color: AppColorsDark.textColor1,
                                  fontSize: 20,
                                ),
                                controller: usernameController,
                                keyboardType: TextInputType.name,
                                cursorColor: AppColorsDark.greenColor,
                                decoration: const InputDecoration(
                                  hintText: "Type Your Name",
                                  hintStyle: TextStyle(
                                    color: AppColorsDark.textColor2,
                                    fontSize: 18,
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColorsDark.greenColor,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColorsDark.greenColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard,
                              color: AppColorsDark.iconColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 24),
                width: 130,
                child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return FutureBuilder(
                            future: addUserInfo(usernameController.text,
                                selectedImage, widget.phone),
                            builder: (context, snapshot) {
                              String? text;
                              Widget? icon;

                              if (snapshot.hasData) {
                                text = "You are all set";
                                icon = Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.check_circle,
                                    color: AppColorsDark.greenColor,
                                    size: 30,
                                  ),
                                );
                                Future.delayed(
                                  const Duration(seconds: 1),
                                  () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => InitializingPage(
                                          phone: widget.phone
                                              .phoneNumberWithoutFormating,
                                        ),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                );
                              } else if (snapshot.hasError) {
                                text = "Oops, an error occured";
                                print(snapshot.error.toString());
                                icon = Container(
                                  decoration: const BoxDecoration(
                                    color: AppColorsDark.errorSnackBarColor,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                  ),
                                  height: 30,
                                  width: 30,
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: AppColorsDark.appBarColor,
                                  ),
                                );
                                Future.delayed(
                                  const Duration(seconds: 2),
                                  () {
                                    Navigator.of(context).pop();
                                  },
                                );
                              }
                              return AlertDialog(
                                actionsPadding: const EdgeInsets.all(0),
                                backgroundColor: AppColorsDark.appBarColor,
                                content: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: icon ??
                                          const CircularProgressIndicator(
                                            color: AppColorsDark.indicatorColor,
                                          ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      text ?? "Connecting",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: AppColorsDark.textColor1,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(AppColorsDark.greenColor),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                    child: const Text("NEXT")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> addUserInfo(
  String username,
  File? selectedImage,
  PhoneNumber phone,
) async {
  if (username.isEmpty) return;

  final id = auth.FirebaseAuth.instance.currentUser!.uid;
  String avatarUrl = 'http://www.gravatar.com/avatar/?d=mp';

  if (selectedImage != null) {
    avatarUrl = await FirebaseStorageUtil.uploadFile(
      "userAvatars/$id",
      selectedImage,
    );
  }
  User user = User(
    name: username,
    id: id,
    status: "Online",
    avatarUrl: avatarUrl,
    phone: phone,
  );
  return await FirestoreDatabase.registerUser(user).then((value) => true);
}

class PhotoOption extends StatelessWidget {
  final Icon icon;
  final String text;
  final Function(File) callback;

  const PhotoOption({
    super.key,
    required this.icon,
    required this.text,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            XFile? image =
                await getSelectedImage();
            if (image == null) {
              return;
            }
            callback(File(image.path));
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColorsDark.iconColor,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: AppColorsDark.appBarColor,
                  child: icon,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          text,
          style: const TextStyle(
            color: AppColorsDark.textColor1,
            fontSize: 16,
            decoration: TextDecoration.none,
            fontFamily: String.fromEnvironment("Consolas"),
          ),
        ),
      ],
    );
  }

  ImageSource getImageSource() {
    if (text == "Camera") {
      return ImageSource.camera;
    }
    return ImageSource.gallery;
  }
}

class InitializingPage extends StatefulWidget {
  final String phone;
  const InitializingPage({super.key, required this.phone});

  @override
  State<InitializingPage> createState() => _InitializingPageState();
}

class _InitializingPageState extends State<InitializingPage> {
  @override
  void initState() {
    Future.delayed(
      const Duration(seconds: 2),
      () async {
        final user = await FirestoreDatabase.getUserByPhoneNumber(
          widget.phone,
        );
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomePage(
              user: user!,
            ),
          ),
          (route) => false,
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColorsDark.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 50),
            child: Text(
              "Initializing",
              style: TextStyle(
                color: AppColorsDark.textColor2,
                fontSize: 30,
              ),
            ),
          ),
          Image(
            image: AssetImage('assets/images/landing_img.png'),
            color: AppColorsDark.greenColor,
            height: 250,
            width: 1140,
          ),
          CircularProgressIndicator(color: AppColorsDark.greenColor),
        ],
      ),
    );
  }
}
