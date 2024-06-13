// Model (SignUpModel)
import 'package:icare/Controller/login_controller.dart';

class LoginModel {
  String email;
  String password;

  LoginModel({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

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
        return true;
      }
      return false;
    } catch (e) {
      print("Error creating a user $e");
      return false;
    }
  }

}
