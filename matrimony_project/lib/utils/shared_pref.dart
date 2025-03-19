
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const String isLoggedInKey = 'isLoggedIn';
  static const String userNameKey = 'userName';
  static const String userEmailKey = 'userEmail';
  static const String userPasswordKey = 'userPassword';

  // Save user registration data
  static Future<void> registerUser(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userNameKey, name);
    await prefs.setString(userEmailKey, email);
    await prefs.setString(userPasswordKey, password);
    await prefs.setBool(isLoggedInKey, true); // Automatically log in after registration
  }

  // Save user login state
  static Future<void> loginUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, true);
    await prefs.setString(userEmailKey, email);
  }

  // Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  // Get user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  // Get user password
  static Future<String?> getUserPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userPasswordKey);
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}