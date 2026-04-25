import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Teacher Role Unit Tests', () {

    test('Teacher Logic: Filter students by Class ID', () {
      // Simulating a list of all students in the database
      List<Map<String, String>> allStudents = [
        {'name': 'Ali', 'class_id': 'A1'},
        {'name': 'Zain', 'class_id': 'B2'},
        {'name': 'Mehran', 'class_id': 'A1'},
      ];

      // Logic: Teacher only wants to see students in Class 'A1'
      String teacherClassId = 'A1';
      List<Map<String, String>> filteredList = allStudents
          .where((student) => student['class_id'] == teacherClassId)
          .toList();

      expect(filteredList.length, 2);
    });

  });
  test('Teacher Logic: Calculate points with bonus', () {
    int basePoints = 50;
    int bonusPoints = 10;
    int finalAwardedPoints = 0;

    // Logic: Teacher approves and adds a bonus
    finalAwardedPoints = basePoints + bonusPoints;

    expect(finalAwardedPoints, 60);
  });

  test('Teacher Logic: Count pending submissions for grading', () {
    List<String> submissionStatuses = ['approved', 'pending', 'pending', 'rejected'];

    // Logic: Count only the 'pending' items
    int pendingCount = submissionStatuses.where((status) => status == 'pending').length;

    expect(pendingCount, 2);
  });
  test('Teacher Logic: Case-insensitive student search', () {
    List<String> studentNames = ['Mehran', 'Ali', 'Zain'];
    String searchQuery = 'mehran'; // User types in lowercase

    // Logic: Search should find 'Mehran' even if query is lowercase
    bool studentFound = studentNames.any(
            (name) => name.toLowerCase() == searchQuery.toLowerCase()
    );

    expect(studentFound, true);
  });


  test('Teacher Security: Access denied for wrong Class ID', () {
    String teacherActualClass = 'Class_A';
    String targetDataClass = 'Class_B';

    // The security logic: If classes don't match, access is false
    bool hasAccess = (teacherActualClass == targetDataClass);

    expect(hasAccess, isFalse); // We expect it to be FALSE (Access Denied)
  });

  test('Teacher Logic: Validate grade is between 0 and 100', () {
    int inputGrade = 105; // Out of range
    bool isValid = true;

    // Logic: Grade must be 0-100
    if (inputGrade < 0 || inputGrade > 100) {
      isValid = false;
    }

    expect(isValid, isFalse);
  });

  
}