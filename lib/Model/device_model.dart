import 'dart:convert';
import 'package:icare/Controller/device_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceModel {
  String id;
  String deviceId;
  String name;
  int age;
  String relationship;
  int userId;

  DeviceModel({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.age,
    required this.relationship,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'name': name,
      'age': age,
      'relationship': relationship,
      'userId': userId,
    };
  }

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'],
      deviceId: json['deviceId'],
      name: json['name'],
      age: json['age'],
      relationship: json['relationship'],
      userId: json['userId'],
    );
  }

  Future<bool> addDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId'); // Ensure userId is retrieved as int
    if (userId == null) {
      print('Error: userId is null');
      return false;
    }
    DeviceController deviceController = DeviceController(path: "/device/addDevice");
    deviceController.setBody(toJson());

    try {
      await deviceController.post();
      int statusCode = deviceController.status();
      if (statusCode == 200) {
        print('JSON data sent: ${jsonEncode(toJson())}');

        Map<String, dynamic>? responseData = await deviceController.result();
        if (responseData != null) {
          print('Raw JSON data: $responseData');
          this.deviceId = responseData['deviceId']; // Update deviceId if needed
          return true;
        } else {
          print('Error: Response data is null');
          return false;
        }
      } else {
        print('Error: HTTP status code $statusCode');
        return false;
      }
    } catch (e) {
      print("Error adding device: $e");
      return false;
    }
  }

  static Future<List<DeviceModel>> getDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userIdString = prefs.getString('userId'); // Retrieve as String
    int? userId = userIdString != null ? int.tryParse(userIdString) : null; // Convert to int

    if (userId == null) {
      print("Error: userId is null or cannot be converted to int");
      return [];
    }

    try {
      DeviceController deviceController = DeviceController(path: "/device/getDevice/userId/$userId");

      await deviceController.get();
      int statusCode = deviceController.status();
      if (statusCode == 200) {
        var responseData = await deviceController.result();
        print('Response data: $responseData');

        if (responseData != null && responseData is List) {
          List<DeviceModel> devices = responseData.map((json) => DeviceModel.fromJson(json)).toList();
          return devices;
        } else {
          print('Error: Response data is null or not a list');
          return [];
        }
      } else {
        print('Failed to fetch devices. Status code: $statusCode');
        return [];
      }
    } catch (e) {
      print("Error fetching devices: $e");
      return [];
    }
  }
}
