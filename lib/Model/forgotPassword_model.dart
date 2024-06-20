import 'package:flutter/material.dart';
import '../Controller/forgotPassword_Controller.dart';

class ForgotPasswordModel {
  String email;

  ForgotPasswordModel({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }

  Future<bool> resetPassword(String email) async {
    // Create an instance of ForgotPasswordController
    ForgotPasswordController forgotPasswordController = ForgotPasswordController(path: "/user/forgotPassword");

    try {
      // Prepare data to be sent in the request body
      Map<String, dynamic> requestData = {
        'email': email,
        // Add any other necessary data here
      };

      // Set the request body in the controller
      forgotPasswordController.setBody(requestData);

      // Send the PUT request using the controller
      await forgotPasswordController.put();

      // Check the status code of the response
      int statusCode = forgotPasswordController.status();
      if (statusCode == 200) {
        // Password reset request successful
        return true;
      } else {
        // Password reset request failed
        print('Failed to reset password. Status code: $statusCode');
        return false;
      }
    } catch (e) {
      // Exception occurred while sending the request
      print('Error sending password reset request: $e');
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    ForgotPasswordController forgotPasswordController = ForgotPasswordController(path: "/user/resetPassword");

    try {
      forgotPasswordController.setBody({
        'email': email,
        'newPassword': newPassword,
        'confirmPassword': newPassword, // Assuming confirmPassword is handled on the frontend
      });

      await forgotPasswordController.put();

      int statusCode = forgotPasswordController.status();
      return statusCode == 200;
    } catch (e) {
      print("Error updating password: $e");
      return false;
    }
  }
}
