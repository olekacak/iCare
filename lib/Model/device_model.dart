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
    int? userId = prefs.getInt('userId');
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
          // Assuming backend returns the deviceId in the response
          deviceId = responseData['deviceId'];
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
      print("Error add device: $e");
      return false;
    }
  }

  static Future<List<DeviceModel>> getDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    print("userId for device: $userId");

    if (userId == null) {
      print("Error: userId is null");
      return [];
    }

    try {
      DeviceController deviceController = DeviceController(path: "/device/getDevice/userId/$userId");

      // Perform GET request to fetch all devices based on userId
      await deviceController.get();

      int statusCode = deviceController.status();
      if (statusCode == 200) {
        var responseData = await deviceController.result();
        print('Response data: $responseData');

        if (responseData != null && responseData is List) {
          // Convert each item in the list to DeviceModel using fromJson
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
