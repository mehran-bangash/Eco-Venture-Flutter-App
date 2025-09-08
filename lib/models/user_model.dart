import 'dart:convert';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final DateTime createdAt;
  final String? token; // optional, in case backend sends token with user

  UserModel({
    required this.uid,
    required this.createdAt,
    required this.email,
    required this.displayName,
    required this.role,
    this.token,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "email": email,
      "displayName": displayName,
      "role": role,
      "createdAt": createdAt.toIso8601String(),
      "token": token,
    };
  }

  // Convert to JSON String
  String toJson() => json.encode(toMap());

  // Factory: handle both flat and nested JSON
  factory UserModel.fromMap(Map<String, dynamic> map) {
    // 🔎 Case 1: Backend sends { user: {...}, token: "..." }
    if (map.containsKey('user')) {
      final userMap = map['user'] as Map<String, dynamic>;
      return UserModel(
        uid: userMap['uid'],
        email: userMap['email'],
        displayName: userMap['displayName'],
        role: userMap['role'],
        createdAt: DateTime.parse(userMap['createdAt']),
        token: map['token'], // token stays at root
      );
    }

    // 🔎 Case 2: Backend sends flat JSON { uid, email, displayName, ... }
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'],
      role: map['role'],
      createdAt: DateTime.parse(map['createdAt']),
      token: map['token'], // may or may not exist
    );
  }

  // Create from JSON string
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? role,
    DateTime? createdAt,
    String? token,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      token: token ?? this.token,
    );
  }
}
