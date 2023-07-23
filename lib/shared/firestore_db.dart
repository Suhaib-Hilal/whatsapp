import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsappclone/features/chat/model/message.dart';
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

  static Future<void> addMessage(Message message) async {
    final receiverDocRef = db
        .collection("users")
        .doc(message.senderId)
        .collection("chats")
        .doc(message.receiverId);

    await receiverDocRef
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());

    final senderDocRef = db
        .collection("users")
        .doc(message.receiverId)
        .collection("chats")
        .doc(message.senderId);

    await senderDocRef
        .collection("messages")
        .doc(message.id)
        .set(message.toMap());
  }

  static Stream<List<Message>> getChatMessages(
      String targetUserId, String chatId) {
    return db
        .collection("users")
        .doc(targetUserId)
        .collection("chats")
        .doc(chatId)
        .collection('messages')
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((event) {
      final messages = <Message>[];
      for (var docSnap in event.docs) {
        messages.add(Message.fromMap(docSnap.data()));
      }
      return messages;
    });
  }
}
