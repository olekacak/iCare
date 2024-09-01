import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../Controller/editProfile_controller.dart';

class EditProfileModel {
  String email;
  String name;
  String phoneNo;
  String address;
  String birthDate;
  String gender;
  String profileImage;

  EditProfileModel({
    required this.email,
    required this.name,
    required this.phoneNo,
    required this.address,
    required this.birthDate,
    required this.gender,
    required this.profileImage,
  });

  factory EditProfileModel.fromJson(Map<String, dynamic> json) {
    return EditProfileModel(
      email: json['email'],
      name: json['name'],
      phoneNo: json['phoneNo'],
      address: json['address'],
      birthDate: json['birthDate'],
      gender: json['gender'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phoneNo': phoneNo,
      'address': address,
      'birthDate': birthDate,
      'gender': gender,
      'profileImage': profileImage,
    };
  }

  static Future<EditProfileModel?> loadByUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId'); // Use getInt to retrieve the userId as an int

    if (userId == null) {
      print("No userId found in SharedPreferences");
      return null;
    }

    try {
      EditProfileController editProfileController = EditProfileController(path: "/user/userId/$userId");

      // Perform GET request to fetch user info
      await editProfileController.get();

      int statusCode = editProfileController.status();
      if (statusCode == 200) {
        var responseData = await editProfileController.result();
        if (responseData != null && responseData is Map<String, dynamic>) {
          return EditProfileModel.fromJson(responseData['user']);
        } else {
          print("Invalid response format. Expected 'user' object.");
        }
      } else {
        print("Failed to fetch user info. Status code: $statusCode");
      }
    } catch (e) {
      print("Error loading user info: $e");
    }

    return null;
  }


  Future<bool> updateUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userIdString = prefs.getString('userId');
    int? userId = userIdString != null ? int.tryParse(userIdString) : null;

    if (userId == null) {
      print("No userId found in SharedPreferences");
      return false;
    }

    EditProfileController editProfileController = EditProfileController(path: "/user/$userId");
    editProfileController.setBody(toJson());

    print('Updating user with data: ${jsonEncode(toJson())}');

    try {
      await editProfileController.put(); // Ensure PUT method is used
      int statusCode = editProfileController.status();
      if (statusCode == 200) {
        print('Profile updated successfully');
        return true;
      } else {
        print('Failed to update profile. Status code: $statusCode');
        return false;
      }
    } catch (e) {
      print("Error updating profile: $e");
      return false;
    }
  }


}
