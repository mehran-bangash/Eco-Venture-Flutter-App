class ChatMessage {
  final String sender; // 'user' or 'bot'
  final String message;
  final DateTime time;
  final String userId;
  final bool isUser;

  ChatMessage({
    required this.sender,
    required this.isUser,
    required this.userId,
    required this.message,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'sender': sender,
      'isUser': isUser ? 1 : 0,
      'message': message,
      'time': time.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    final isUserVal = map['isUser'];
    bool isUserBool;
    if (isUserVal is int) {
      isUserBool = isUserVal == 1;
    } else if (isUserVal is String) {
      isUserBool = isUserVal == '1' || isUserVal.toLowerCase() == 'true';
    } else {
      // fallback: use sender string
      isUserBool = (map['sender']?.toString().toLowerCase() == 'user');
    }

    return ChatMessage(
      userId: map['userId'] ?? '',
      sender: map['sender'] ?? (isUserBool ? 'user' : 'bot'),
      isUser: isUserBool,
      message: map['message'] ?? '',
      time: DateTime.parse(map['time']),
    );
  }
}
