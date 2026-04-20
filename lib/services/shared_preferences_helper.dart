import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  SharedPreferencesHelper._();

  static final SharedPreferencesHelper instance = SharedPreferencesHelper._();

  // Issue #4 Solved: Single instance to avoid repeated disk access
  static SharedPreferences? _prefs;

  // Call this in main.dart: await SharedPreferencesHelper.init();
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Helper to access the initialized instance safely
  SharedPreferences get _p => _prefs!;

  // Keys
  static String userIdKey = 'USERIDKEY';
  static String userNameKey = 'USERNAMEKEY';
  static String userEmailKey = 'USEREMAILKEY';
  static String userRoleKey = 'USERROLEKEY';
  static String userPhoneNumberKey = 'USERPHONENUMBERKEY';
  static String userImgUrlKey = 'USERIMGURLKEY';
  static String userDOBKey = 'USERDOBKEY';
  static String userTokenKey = 'USERTOKENKEY';
  static String userAgeGroupKey = 'USERAGEGROUPKEY';
  static const String childTeacherIdKey = 'child_teacher_id';
  static const String isTeacherAddedKey = 'is_teacher_added';
  static const String childNameKey = 'child_name';
  static const String childEmailKey = 'child_email';
  static const String isFirstTimeKey = 'ISFIRSTTIMEKEY';

  // --- Onboarding ---
  Future<bool> saveIsFirstTime(bool isFirstTime) async =>
      await _p.setBool(isFirstTimeKey, isFirstTime);
  bool getIsFirstTime() => _p.getBool(isFirstTimeKey) ?? true;

  // --- Setters (Save) ---
  Future<bool> saveUserId(String userId) async =>
      await _p.setString(userIdKey, userId);
  Future<bool> saveUserName(String userName) async =>
      await _p.setString(userNameKey, userName);
  Future<bool> saveUserEmail(String userEmail) async =>
      await _p.setString(userEmailKey, userEmail);
  Future<bool> saveUserRole(String userRole) async =>
      await _p.setString(userRoleKey, userRole);
  Future<bool> saveUserAgeGroup(String ageGroup) async =>
      await _p.setString(userAgeGroupKey, ageGroup);
  Future<bool> saveUserImgUrl(String imgUrl) async =>
      await _p.setString(userImgUrlKey, imgUrl);
  Future<bool> saveUserDOB(String dOB) async =>
      await _p.setString(userDOBKey, dOB);
  Future<bool> saveUserToken(String userToken) async =>
      await _p.setString(userTokenKey, userToken);
  Future<bool> saveUserPhoneNumber(String userPhoneNumber) async =>
      await _p.setString(userPhoneNumberKey, userPhoneNumber);

  // --- Getters (Read - Now Synchronous for Performance) ---
  String? getUserId() => _p.getString(userIdKey);
  String? getUserEmail() => _p.getString(userEmailKey);
  String? getUserName() => _p.getString(userNameKey);
  String? getUserRole() => _p.getString(userRoleKey);
  String? getUserAgeGroup() => _p.getString(userAgeGroupKey);
  String? getUserImgUrl() => _p.getString(userImgUrlKey);
  String? getUserPhoneNumber() => _p.getString(userPhoneNumberKey);
  String? getUserDOB() => _p.getString(userDOBKey);

  // --- Child/Teacher Logic ---
  Future<bool> saveChildName(String name) async =>
      await _p.setString(childNameKey, name);
  String? getChildName() => _p.getString(childNameKey);

  Future<bool> saveChildEmail(String email) async =>
      await _p.setString(childEmailKey, email);
  String? getChildEmail() => _p.getString(childEmailKey);

  Future<bool> saveChildTeacherId(String teacherId) async =>
      await _p.setString(childTeacherIdKey, teacherId);
  String? getChildTeacherId() => _p.getString(childTeacherIdKey);

  Future<bool> saveIsTeacherAdded(bool isAdded) async =>
      await _p.setBool(isTeacherAddedKey, isAdded);
  bool getIsTeacherAdded() => _p.getBool(isTeacherAddedKey) ?? false;

  // --- Cleanup ---
  Future<void> clearAll() async {
    await _p.remove(userIdKey);
    await _p.remove(userNameKey);
    await _p.remove(userEmailKey);
    await _p.remove(userRoleKey);
    await _p.remove(userPhoneNumberKey);
    await _p.remove(userImgUrlKey);
    await _p.remove(userDOBKey);
    await _p.remove(userTokenKey);
    await _p.remove(userAgeGroupKey);
    await _p.remove(childTeacherIdKey);
    await _p.remove(isTeacherAddedKey);
    await _p.remove(childNameKey);
    await _p.remove(childEmailKey);
  }
}
