import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserUtils {
  
  static Future<UserAccount?> readUser() async {
    final User user = await FirebaseAuth.instance.currentUser!;

    final docUser =
        FirebaseFirestore.instance.collection("users").doc(user.uid);
    final snapshot = await docUser.get();

    if (snapshot.exists) {
      return UserAccount.fromJson(snapshot.data()!);
    }
  }

  static Future<UserAccount?> getUser(String userID) async {

    final docUser =
        FirebaseFirestore.instance.collection("users").doc(userID);
    final snapshot = await docUser.get();

    if (snapshot.exists) {
      return UserAccount.fromJson(snapshot.data()!);
    }
  }
}

class UserAccount {
  final bool admin;
  final String name;
  final int age;

  UserAccount({
    required this.admin,
    required this.name,
    required this.age,
  });

  Map<String, dynamic> toJson() => {
        'admin': admin,
        'name': name,
        'age': age,
      };

  static UserAccount fromJson(Map<String, dynamic> json) =>
      UserAccount(admin: json['admin'], name: json['name'], age: json['age']);
}
