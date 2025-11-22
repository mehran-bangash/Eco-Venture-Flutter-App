class StemSubmissionModel {
  final String? id;
  final String challengeId;
  final String studentId;
  final String challengeTitle;

  // CHANGE 1: List of Strings instead of single String
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
    required this.challengeTitle,
    required this.proofImageUrls, // Updated
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
      'challenge_title': challengeTitle,
      'proof_image_urls': proofImageUrls, // Updated key
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
      challengeTitle: map['challenge_title'] ?? '',
      // Updated parsing logic
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
    String? challengeTitle,
    List<String>? proofImageUrls, // Updated type
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
      challengeTitle: challengeTitle ?? this.challengeTitle,
      proofImageUrls: proofImageUrls ?? this.proofImageUrls,
      daysTaken: daysTaken ?? this.daysTaken,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      teacherFeedback: teacherFeedback ?? this.teacherFeedback,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
    );
  }
}