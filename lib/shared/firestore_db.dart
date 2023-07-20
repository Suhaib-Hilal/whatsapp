import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsappclone/shared/user.dart';

final db = FirebaseFirestore.instance;

class FirestoreDatabase {
  static Future<void> registerUser(User user) async {
    await db.collection("users").doc(user.id).set(user.toMap());
  }

  static Future<User?> getUserById(String userId) async {
    final docRef = db.collection("users").doc(userId);
    final docSnap = await docRef.get();
    if (docSnap.data() == null) {
      return null;
    }
    return User.fromMap(docSnap.data()!);
  }

  static Future<User?> getUserByPhoneNumber(String phoneNumber) async {
    final collectionRef = db.collection("users");
    final query = collectionRef.where(
      "phone.phoneNumberWithoutFormating",
      isEqualTo: phoneNumber,
    );
    final querySnap = await query.get();
    return querySnap.docs.isEmpty
        ? null
        : User.fromMap(querySnap.docs[0].data());
  }
}
