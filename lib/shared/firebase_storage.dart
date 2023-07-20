import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

final firebaseStorageRef = FirebaseStorage.instance.ref();
class FirebaseStorageUtil {
  static Future<String> uploadFile(String path, File file) async {
    final taskSnap = await firebaseStorageRef.child(path).putFile(file);
    return await taskSnap.ref.getDownloadURL();
  }
}
