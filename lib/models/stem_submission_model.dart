class StemSubmissionModel {
  final String? id;
  final String challengeId;
  final String studentId;
  final String studentName;
  final String? studentProfilePic; // NEW: For Teacher UI
  final String challengeTitle;
  final String category; // NEW: For Filtering (Science, Math...)
  final String difficulty; // NEW: For Grading Context
  final List<String> proofImageUrls;
  final int daysTaken;
  final DateTime submittedAt;
  final String status;
  final String? teacherFeedback;
  final int pointsAwarded;

  StemSubmissionModel({
    this.id,
    required this.challengeId,
    required this.studentId,
    required this.studentName,
    this.studentProfilePic, // Optional
    required this.challengeTitle,
    required this.category, // Req
    required this.difficulty, // Req
    required this.proofImageUrls,
    required this.daysTaken,
    required this.submittedAt,
    this.status = 'pending',
    this.teacherFeedback,
    this.pointsAwarded = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'challenge_id': challengeId,
      'student_id': studentId,
      'student_name': studentName,
      'student_profile_pic': studentProfilePic, // Save
      'challenge_title': challengeTitle,
      'category': category, // Save
      'difficulty': difficulty, // Save
      'proof_image_urls': proofImageUrls,
      'days_taken': daysTaken,
      'submitted_at': submittedAt.toIso8601String(),
      'status': status,
      'teacher_feedback': teacherFeedback,
      'points_awarded': pointsAwarded,
    };
  }

  factory StemSubmissionModel.fromMap(String id, Map<String, dynamic> map) {
    return StemSubmissionModel(
      id: id,
      challengeId: map['challenge_id'] ?? '',
      studentId: map['student_id'] ?? '',
      studentName: map['student_name'] ?? 'Unknown',
      studentProfilePic: map['student_profile_pic'], // Read
      challengeTitle: map['challenge_title'] ?? '',
      category: map['category'] ?? '', // Read
      difficulty: map['difficulty'] ?? '', // Read
      proofImageUrls: List<String>.from(map['proof_image_urls'] ?? []),
      daysTaken: map['days_taken']?.toInt() ?? 0,
      submittedAt: DateTime.tryParse(map['submitted_at'] ?? '') ?? DateTime.now(),
      status: map['status'] ?? 'pending',
      teacherFeedback: map['teacher_feedback'],
      pointsAwarded: map['points_awarded']?.toInt() ?? 0,
    );
  }

  StemSubmissionModel copyWith({
    String? id,
    String? challengeId,
    String? studentId,
    String? studentName,
    String? studentProfilePic,
    String? challengeTitle,
    String? category,
    String? difficulty,
    List<String>? proofImageUrls,
    int? daysTaken,
    DateTime? submittedAt,
    String? status,
    String? teacherFeedback,
    int? pointsAwarded,
  }) {
    return StemSubmissionModel(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentProfilePic: studentProfilePic ?? this.studentProfilePic,
      challengeTitle: challengeTitle ?? this.challengeTitle,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      proofImageUrls: proofImageUrls ?? this.proofImageUrls,
      daysTaken: daysTaken ?? this.daysTaken,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      teacherFeedback: teacherFeedback ?? this.teacherFeedback,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
    );
  }
}