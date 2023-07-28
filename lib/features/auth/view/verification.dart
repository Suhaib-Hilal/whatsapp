import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/color_theme.dart';
import '../model/phone_number.dart';
import '../../../utils/abc.dart';
import 'user_profile.dart';

class VerificationPage extends StatefulWidget {
  final PhoneNumber phoneNumber;

  const VerificationPage({super.key, required this.phoneNumber});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final focusNodes = List.generate(6, (index) => FocusNode());
  late List<SizedBox> textFields;
  String verificationId = "";
  String code = "";
  int initialTime = 60;
  int currentTime = 60;
  Color color = AppColorsDark.greyColor;
  int resendCount = 1;
  Timer timer = Timer(const Duration(microseconds: 1), () => ());

  @override
  void initState() {
    focusNodes[0].requestFocus();
    textFields = List.generate(6, (index) {
      return SizedBox(
        width: 20,
        height: 20,
        child: TextField(
          onChanged: (value) {
            setState(() {});
            if (value.isEmpty) {
              if (index != 0) {
                focusNodes[index - 1].requestFocus();
                setState(() => code = code.substring(index));
              }
            } else {
              if (index == 5) {
                code += value;
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FutureBuilder(
                      future: verifyOtp(code),
                      builder: (context, snapshot) {
                        String? text;
                        Widget? icon;

                        if (snapshot.hasData) {
                          text = "Verification Complete";
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
                            const Duration(seconds: 2),
                            () {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => UserProfilePage(
                                        phone: widget.phoneNumber),
                                  ),
                                  (route) => false);
                            },
                          );
                        } else if (snapshot.hasError) {
                          text = "Invalid OTP";
                          icon = Container(
                            decoration: const BoxDecoration(
                                color: AppColorsDark.errorSnackBarColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
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
                return;
              }
              code += value;
              focusNodes[index + 1].requestFocus();
            }
          },
          textAlign: TextAlign.center,
          focusNode: focusNodes[index],
          maxLength: 1,
          style: const TextStyle(
            color: AppColorsDark.textColor1,
            fontSize: 20,
          ),
          keyboardType: const TextInputType.numberWithOptions(),
          decoration: const InputDecoration(
            hintText: " -",
            hintStyle: TextStyle(
              color: AppColorsDark.textColor1,
              fontSize: 20,
            ),
            counterText: "",
            border: InputBorder.none,
          ),
        ),
      );
    });

    sendNewOtp();

    super.initState();
  }

  void sendNewOtp() {
    sendOtp(widget.phoneNumber.phoneNumberWithoutFormating, (vId) {
      setTimer();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "OTP SENT!",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: AppColorsDark.greenColor,
        behavior: SnackBarBehavior.floating,
      ));
      setState(() => verificationId = vId);
    });
  }

  void setTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timer.tick;
      currentTime--;
      if (currentTime == 0) {
        currentTime = initialTime * resendCount * 5;
        timer.cancel();
      }
      setState(() {});
    });
    resendCount++;
  }

  @override
  void dispose() {
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    timer.cancel();
    super.dispose();
  }

  Future<void> verifyOtp(String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    return await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((value) => true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsDark.backgroundColor,
      appBar: AppBar(
        title: const Center(child: Text("Verifying your number")),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: AppColorsDark.appBarColor,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColorsDark.backgroundColor,
        ),
        backgroundColor: AppColorsDark.appBarColor,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height / 2.5,
        decoration: const BoxDecoration(
          color: AppColorsDark.backgroundColor,
        ),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text:
                    'Waiting to automatically detect an SMS sent to ${widget.phoneNumber.phoneNumberWithoutFormating} ',
                children: const <TextSpan>[
                  TextSpan(
                    text: "Wrong Number?",
                    style: TextStyle(
                      color: AppColorsDark.blueColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.8,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: textFields.sublist(0, 3),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: textFields.sublist(3),
                      ),
                    ],
                  ),
                  const Divider(
                    color: AppColorsDark.greenColor,
                    thickness: 3,
                  ),
                ],
              ),
            ),
            const Text(
              "Enter 6-digit code",
              style: TextStyle(
                color: AppColorsDark.textColor1,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.message_sharp,
                color: timer.isActive
                    ? AppColorsDark.greyColor
                    : AppColorsDark.greenColor,
              ),
              title: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  child: Text(
                    "Resend SMS",
                    style: TextStyle(
                      color: timer.isActive
                          ? AppColorsDark.greyColor
                          : AppColorsDark.greenColor,
                      fontSize: 14,
                    ),
                  ),
                  onPressed: () {
                    sendNewOtp();
                  },
                ),
              ),
              trailing: Text(
                timer.isActive ? formattedTime(currentTime) : "",
                style: const TextStyle(
                  color: AppColorsDark.greyColor,
                  fontSize: 14,
                ),
              ),
            ),
            const Divider(
              color: AppColorsDark.dividerColor,
              height: 5,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            )
          ],
        ),
      ),
    );
  }
}

Future<void> sendOtp(String phoneNumber, Function(String) onCodeSent) async {
  await FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: (PhoneAuthCredential credential) {},
    verificationFailed: (FirebaseAuthException e) {},
    codeSent: (String verificationId, int? resendToken) async {
      onCodeSent(verificationId);
    },
    codeAutoRetrievalTimeout: (String verificationId) {},
  );
}
