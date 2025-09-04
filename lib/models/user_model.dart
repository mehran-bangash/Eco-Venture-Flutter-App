import 'dart:convert';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "email": email,
      "displayName": displayName,
      "role": role,
    };
  }

  // Convert to JSON
  String toJson() => json.encode(toMap());

  // Create object from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'],
      role: map['role'],
    );
  }

  // Create object from JSON
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? role,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
    );
  }
}
