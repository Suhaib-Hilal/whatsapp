import 'package:flutter/material.dart';
import 'login.dart';
import '../../../theme/color_theme.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsDark.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 50),
            child: Text(
              "Welcome to WhatsApp",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
              ),
            ),
          ),
          const Image(
            image: AssetImage('assets/images/landing_img.png'),
            color: AppColorsDark.greenColor,
            height: 250,
            width: 1140,
          ),
          Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'Read our ',
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Privacy Policy. ',
                      style: TextStyle(
                        color: AppColorsDark.blueColor,
                      ),
                    ),
                    TextSpan(text: 'Tap "Agree and Continue" to accept the '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: AppColorsDark.blueColor,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (route) => false);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(AppColorsDark.greenColor),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                    child: const Text("AGREE AND CONTINUE"),
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
