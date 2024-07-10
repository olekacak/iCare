  import 'dart:convert';
  import 'dart:io';
  import 'package:icare/Controller/signup_controller.dart';

  class SignUpModel {
    String userId; // New attribute
    String email;
    String password;
    String name;
    String phoneNo;
    String address;
    String birthDate;
    String gender;
    String profileImage;

    SignUpModel({
      required this.userId,
      required this.email,
      required this.password,
      required this.name,
      required this.phoneNo,
      required this.address,
      required this.birthDate,
      required this.gender,
      required this.profileImage,
    });

    Map<String, dynamic> toJson() {
      return {
        'userId': userId, // Include userId in the JSON representation
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

    Future<bool> signUp() async {
      SignUpController signUpController = SignUpController(path: "/auth/signup");
      signUpController.setBody(toJson());

      try {
        await signUpController.post();
        int statusCode = signUpController.status();
        if (statusCode == 200) {
          print('Sign up successful');
          print('JSON data sent: ${jsonEncode(toJson())}');

          Map<String, dynamic>? responseData = await signUpController.result();
          if (responseData != null) {
            print('Raw JSON data: $responseData');
            // Assuming backend returns the userId in the response
            userId = responseData['userId'];
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
        print("Error signing up: $e");
        return false;
      }
    }
  }
