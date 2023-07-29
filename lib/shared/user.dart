import '../features/auth/model/phone_number.dart';

class User {
  String name;
  String id;
  String status;
  String avatarUrl;
  PhoneNumber phone;

  User({
    required this.name,
    required this.id,
    required this.status,
    required this.avatarUrl,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "id": id,
      "status": status,
      "avatarUrl": avatarUrl,
      "phone": phone.toMap(),
    };
  }

  factory User.fromMap(Map<String, dynamic> userData) {
    return User(
      name: userData["name"],
      id: userData["id"],
      status: userData["status"],
      avatarUrl: userData["avatarUrl"],
      phone: PhoneNumber.fromMap(userData["phone"]),
    );
  }
}
