import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

final firebaseStorageRef = FirebaseStorage.instance.ref();

class FirebaseStorageUtil {
  static Future<String> uploadFile(String path, File file) async {
    final taskSnap = await firebaseStorageRef.child(path).putFile(file);
    return await taskSnap.ref.getDownloadURL();
  }

  static Future<DownloadTask> downloadFileFromFirebase(
    String url,
    String name,
  ) async {
    final ref = FirebaseStorage.instance.refFromURL(url);
    
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$name');

    return ref.writeToFile(file);
  }
}