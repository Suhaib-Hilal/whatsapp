import 'package:flutter/material.dart';
import '../../../theme/color_theme.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsDark.backgroundColor,
      appBar: AppBar(
        title: const Center(child: Text("Profile info")),
        backgroundColor: AppColorsDark.appBarColor,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
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
                      const CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColorsDark.dividerColor,
                        child: Icon(Icons.add_a_photo),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const SizedBox(width: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 40,
                            child: const TextField(
                              style: TextStyle(
                                color: AppColorsDark.textColor1,
                                fontSize: 20,
                              ),
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
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
                    ],
                  ),
                ),
              ),
              SizedBox(
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
