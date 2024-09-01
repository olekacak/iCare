import 'dart:convert';

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

      if (loginController.status() == 200) {
        Map<String, dynamic> result = await loginController.result();

        int? userId = result['user']['userId'];

        if (userId != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', userId); // Save userId as int
          print("UserId saved to SharedPreferences: $userId");
          await prefs.setString('email', email);
          print("Email saved to SharedPreferences: $email");

          await _storeUserData(result['user']);

          // Handle and store device information if available
          List<dynamic> devices = result['devices'] ?? [];
          await _storeDeviceData(devices);

          // Check and print stored device data
          await _checkStoredDeviceData();

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

    // Convert the userData map to a JSON string and store it
    String userDataJson = jsonEncode(userData);
    await prefs.setString('userData', userDataJson);

    print("User data saved to SharedPreferences.");
  }


  Future<void> _storeDeviceData(List<dynamic> devices) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Clear existing device data
    await prefs.remove('deviceId');
    await prefs.remove('deviceName');

    List<String> deviceIdList = [];
    List<String> deviceNameList = [];

    for (var device in devices) {
      if (device is Map<String, dynamic>) {
        String? id = device['deviceId'];
        String? name = device['name'];

        if (id != null) {
          deviceIdList.add(id);
        }
        if (name != null) {
          deviceNameList.add(name);
        }
      }
    }

    // Store device IDs and names in SharedPreferences using the desired keys
    await prefs.setStringList('deviceId', deviceIdList);
    await prefs.setStringList('deviceName', deviceNameList);

    print("Device data saved to SharedPreferences.");
  }

  Future<void> _checkStoredDeviceData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve and print stored device IDs and names
    List<String>? deviceIdList = prefs.getStringList('deviceId');
    List<String>? deviceNameList = prefs.getStringList('deviceName');

    print("Stored Device IDs: $deviceIdList");
    print("Stored Device Names: $deviceNameList");
  }
}
