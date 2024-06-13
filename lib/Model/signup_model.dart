// Model (SignUpModel)
import 'package:icare/Controller/signup_controller.dart';

class SignUpModel {
  String email;
  String password;

  SignUpModel({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  Future<bool> signUp() async {
    SignUpController signUpController = SignUpController(path: "/auth/signup");
    signUpController.setBody({
      'email': email,
      'password': password,
    });

    try {
      await signUpController.post();
      if (signUpController.status() == 200) {
        Map<String, dynamic> result = await signUpController.result();
        return true;
      }
      return false;
    } catch (e) {
      print("Error creating a user $e");
      return false;
    }
  }

}
