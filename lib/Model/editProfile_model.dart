import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../Controller/editProfile_controller.dart';

class EditProfileModel {
  String email;
  String password;
  String name;
  String phoneNo;
  String address;
  String birthDate;
  String gender;
  String profileImage;

  EditProfileModel({
    required this.email,
    required this.password,
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
      password: json['password'],
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
      'password': password,
      'name': name,
      'phoneNo': phoneNo,
      'address': address,
      'birthDate': birthDate,
      'gender': gender,
      'profileImage': profileImage,
    };
  }

  static Future<EditProfileModel?> loadByEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    if (email == null) {
      print("No email found in SharedPreferences");
      return null;
    }

    try {
      EditProfileController editProfileController = EditProfileController(path: "/auth/user?email=$email");

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



  Future<bool> updateUser(String email) async {
    EditProfileController editProfileController = EditProfileController(path: "/auth/user/$email");
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
