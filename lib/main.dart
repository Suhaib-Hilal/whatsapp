import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:whatsappclone/features/home/view/home_page.dart';
import 'package:whatsappclone/shared/firestore_db.dart';
import 'package:whatsappclone/shared/user.dart';
import 'package:whatsappclone/theme/color_theme.dart';
import 'features/auth/view/welcome.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const WhatsApp());
}

class WhatsApp extends StatelessWidget {
  const WhatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      title: 'Flutter Demo',
      home: StreamBuilder<auth.User?>(
        stream: auth.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const WelcomePage();
          }

          final user = snapshot.data!;
          return FutureBuilder<User?>(
            future: FirestoreDatabase.getUserById(user.uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  color: AppColorsDark.backgroundColor,
                  child: const Center(
                    child: Image(
                      image: AssetImage("assets/images/landing_img.png"),
                      color: AppColorsDark.greenColor,
                      width: 100,
                    ),
                  ),
                );
              }

              return HomePage(user: snapshot.data!);
            },
          );
        },
      ),
    );
  }
}
