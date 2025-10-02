import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  SharedPreferencesHelper._();

  static SharedPreferencesHelper instance =
      SharedPreferencesHelper._();
  static String userIdKey = 'USERIDKEY';
  static String userNameKey = 'USERNAMEKEY';
  static String userEmailKey = 'USEREMAILKEY';
  static String userRoleKey = 'USERROLEKEY';
  static String userPhoneNumberKey = 'USERPHONENUMBERKEY';
  static String userImgUrlKey = 'USERIMGURLKEY';
  static String userDOBKey = 'USERDOBKEY';
  static String userTokenKey = 'USERTOKENKEY';
  static String userImageUrlKey='USERIMAGEURLKEY';

  Future<bool> saveUserId(String userId) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(userIdKey, userId);
  }
  Future<bool> saveUserImgUrl(String imgUrl)async{
    final pref = await SharedPreferences.getInstance();
    return pref.setString(userImgUrlKey, imgUrl);
  }
  Future<bool> saveUserName(String userName) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(userNameKey, userName);
  }

  Future<bool> saveUserEmail(String userEmail) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(userEmailKey, userEmail);
  }
  Future<bool> saveUserDOB(String dOB) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(userDOBKey, dOB);
  }

  Future<bool> saveUserRole(String userRole) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(userRoleKey, userRole);
  }

  Future<bool> saveUserToken(String userToken) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(userTokenKey, userToken);
  }

  Future<bool> saveUserPhoneNumber(String userPhoneNumber) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(userPhoneNumberKey, userPhoneNumber);
  }


  Future<String?> getUserId() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(userIdKey);
  }

  Future<String?> getUserEmail() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(userEmailKey);
  }

  Future<String?> getUserName() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(userNameKey);
  }

  Future<String?> getUserPhoneNumber() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(userPhoneNumberKey);
  }

  Future<String?> getUserRole() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(userRoleKey);
  }
  Future<String?> getImageUrl() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(userImgUrlKey);
  }
  Future<String?> getUserDOB() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(userDOBKey);
  }

  Future<String?> getUserImgUrl() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(userImgUrlKey);
  }

  Future<void> clearAll() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(userIdKey);
    await pref.remove(userNameKey);
    await pref.remove(userEmailKey);
    await pref.remove(userRoleKey);
    await pref.remove(userPhoneNumberKey);
    await pref.remove(userImgUrlKey);
    await pref.remove(userDOBKey);
    await pref.remove(userTokenKey);
    await pref.remove(userImgUrlKey);
  }

}
