import '../features/auth/model/phone_number.dart';

class User {
  String name;
  String id;
  String avatarUrl;
  PhoneNumber phone;

  User({
    required this.name,
    required this.id,
    required this.avatarUrl,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "id": id,
      "avatarUrl": avatarUrl,
      "phone": phone.toMap(),
    };
  }

  factory User.fromMap(Map<String, dynamic> userData) {
    return User(
      name: userData["name"],
      id: userData["id"],
      avatarUrl: userData["avatarUrl"],
      phone: PhoneNumber.fromMap(userData["phone"]),
    );
  }
}
