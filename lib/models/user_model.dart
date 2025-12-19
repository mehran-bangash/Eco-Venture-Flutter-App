import 'dart:convert';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final DateTime createdAt;
  final String? imgUrl;
  final String? phoneNumber;
  final String? token; // optional, in case backend sends token with user

  UserModel({
    required this.uid,
    this.imgUrl,
    this.phoneNumber,
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
      "imgUrl": imgUrl,
      "phoneNumber": phoneNumber,
    };
  }

  // Convert to JSON String
  String toJson() => json.encode(toMap());
  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Helper function: Safely converts ANYTHING to a String to prevent crashes
    String safeString(dynamic value) {
      if (value == null) return "";
      if (value is String) return value;
      return value.toString(); // Fixes "Map is not subtype of string" error
    }

    //  Case 1: Backend sends { user: {...}, token: "..." }
    if (map.containsKey('user') && map['user'] is Map) {
      final userMap = map['user'] as Map<String, dynamic>;
      return UserModel(
        uid: safeString(userMap['uid']),
        imgUrl: safeString(userMap['imgUrl']),
        phoneNumber: safeString(userMap['phoneNumber']),
        email: safeString(userMap['email']),
        displayName: safeString(userMap['displayName']),
        role: safeString(userMap['role']),
        // Safe Date Parsing
        createdAt: userMap['createdAt'] != null
            ? DateTime.tryParse(userMap['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        token: safeString(map['token']),
      );
    }

    //  Case 2: Flat JSON
    return UserModel(
      uid: safeString(map['uid']),
      email: safeString(map['email']),
      displayName: safeString(map['displayName']),
      imgUrl: safeString(map['imgUrl']),
      phoneNumber: safeString(map['phoneNumber']),
      role: safeString(map['role']),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      token: safeString(map['token']),
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
    String? imgUrl,
    String? phoneNumber,
    String? token,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      imgUrl: imgUrl ?? this.imgUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      token: token ?? this.token,
    );
  }
}
