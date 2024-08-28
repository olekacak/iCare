import 'package:shared_preferences/shared_preferences.dart';
import '../Controller/login_controller.dart';

class LoginModel {
  String email;
  String password;

  LoginModel({required this.email, required this.password});

  Future<bool> login() async {
    LoginController loginController = LoginController(path: "/auth/login");
    loginController.setBody({
      'email': email,
      'password': password,
    });

    try {
      await loginController.post();
      print("Login request sent. Status code: ${loginController.status()}");

      if (loginController.status() == 200) {
        Map<String, dynamic> result = await loginController.result();
        print("Login successful. Response: $result");

        String? userIdString = result['user']['userId']?.toString();
        int? userId = userIdString != null ? int.tryParse(userIdString) : null;

        if (userId != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', userId); // Save userId as int
          print("UserId saved to SharedPreferences: $userId");
          await prefs.setString('email', email);
          print("Email saved to SharedPreferences: $email");

          await _storeUserData(result['user']);
          return true;
        } else {
          print("UserId not found in response or cannot be converted to int");
          return false;
        }
      } else {
        print("Error: Status code ${loginController.status()}");
        return false;
      }
    } catch (e) {
      print("Error logging in: $e");
      return false;
    }
  }



  Future<void> _storeUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Store each attribute from userData into SharedPreferences
    userData.forEach((key, value) {
      if (value is String) {
        prefs.setString(key, value);
      } else if (value is int) {
        prefs.setInt(key, value);
      } else if (value is bool) {
        prefs.setBool(key, value);
      } else if (value is double) {
        prefs.setDouble(key, value);
      } else if (value is List<String>) {
        prefs.setStringList(key, value);
      } else {
        // Handle other types as needed
        prefs.setString(key, value.toString()); // Fallback to store as string
      }
    });
  }
}
