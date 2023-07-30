import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsappclone/features/chat/model/message.dart';
import 'package:whatsappclone/features/home/model/recent_chat.dart';
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

  static Stream<List<RecentChat>> getRecentChats(User user) {
    return db
        .collection("chats")
        .doc(user.id)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .asyncMap(
      (event) async {
        final recentChats = <RecentChat>[];
        final visited = <String>{};

        for (var docChange in event.docChanges) {
          final docData = docChange.doc.data()!;

          final authorId = docData['senderId'] == user.id
              ? docData['receiverId']
              : docData['senderId'];

          if (visited.contains(authorId)) continue;
          final author = await FirestoreDatabase.getUserById(authorId);

          recentChats.add(
            RecentChat(
              author: author!,
              lastMsg: Message.fromMap(docData),
            ),
          );
          visited.add(authorId);
        }
        return recentChats;
      },
    );
  }

  static Future<void> sendMessage(Message message) async {
    await db
        .collection("chats")
        .doc(message.senderId)
        .collection("messages")
        .doc(message.id)
        .set(message.toMap());

    await db
        .collection("chats")
        .doc(message.receiverId)
        .collection("messages")
        .doc(message.id)
        .set(message.toMap());
  }

  static Stream<List<Message>> getChatMessages(String selfId, String otherId) {
    return db
        .collection("chats")
        .doc(selfId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .where("senderId", whereIn: [selfId, otherId])
        .snapshots()
        .asyncMap(
          (event) async {
            final messages = <Message>[];
            for (var docSnap in event.docs) {
              var message = Message.fromMap(docSnap.data());
              messages.add(message);

              if (message.senderId == otherId && message.status != "SEEN") {
                await changeMessageStatus(message, "SEEN");
              }
            }
            return messages;
          },
        );
  }

  static Stream<String?> getUserStatus(String userId) {
    return db
        .collection("users")
        .doc(userId)
        .snapshots()
        .map((event) => event.data()!["status"]);
  }

  static Future<void> updateUserStatus(String userId, String value) async {
    await db.collection("users").doc(userId).update({"status": value});
  }

  static Future<void> changeMessageStatus(Message message, String value) async {
    await db
        .collection("chats")
        .doc(message.senderId)
        .collection("messages")
        .doc(message.id)
        .update({"status": value});
  }
}
