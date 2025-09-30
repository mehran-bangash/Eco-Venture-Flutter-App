class ApiConstants {
  // Change manually depending on test environment
 static const String baseUrl = "http://10.0.2.2:5000/"; // Emulator
 //static const String baseUrl = "http://192.168.0.182:5000/"; // Real Device
  static const String signInEndpoint = "${baseUrl}signIn";
  static const String signUpEndpoint =   "${baseUrl}signup";
  static const String googleEndpoint =   "${baseUrl}google";
  static const String getUserEndpoint = "${baseUrl}user";
}
