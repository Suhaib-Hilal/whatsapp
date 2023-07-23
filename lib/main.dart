import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:whatsappclone/features/auth/view/home_page.dart';
import 'package:whatsappclone/shared/firestore_db.dart';
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
      title: 'Flutter Demo',
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const WelcomePage();
          }

          final user = snapshot.data!;
          return FutureBuilder(
            future: FirestoreDatabase.getUserById(user.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return HomePage(user: snapshot.data!);
              } else if (snapshot.hasError) {
                return Container(
                  color: Colors.red,
                  child: Center(
                    child: Text(snapshot.error.toString()),
                  ),
                );
              }
              return const Center(
                child: Image(
                  image: AssetImage("assets/images/landing_img.png"),
                  width: 100,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
