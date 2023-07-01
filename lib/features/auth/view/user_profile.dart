import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/color_theme.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

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
                                              setState(
                                                  () => selectedImage = file);
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
                    onPressed: () {},
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
                await ImagePicker().pickImage(source: getImageSource());
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
