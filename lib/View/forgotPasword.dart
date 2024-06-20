import 'package:flutter/material.dart';
import '../Model/forgotPassword_model.dart';
import 'login.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;
  String? _successMessage;
  bool _isEmailEntered = false;
  bool _isEmailValid = false;

  Future<void> checkEmail() async {
    String email = _emailController.text.trim();

    try {
      // Simulating email existence check (replace with actual logic)
      bool emailExists = true; // Replace with actual backend check

      if (emailExists) {
        setState(() {
          _errorMessage = null;
          _successMessage = null; // Clear success message if shown previously
          _isEmailEntered = true;
          _isEmailValid = true;
        });
      } else {
        setState(() {
          _isEmailEntered = true;
          _isEmailValid = false;
          _errorMessage = 'Email not found';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
      });
    }
  }

  Future<void> resetPassword() async {
    String email = _emailController.text.trim();
    String newPassword = _passwordController.text;

    try {
      ForgotPasswordModel model = ForgotPasswordModel(email: email);
      bool passwordUpdated = await model.updatePassword(newPassword);

      if (passwordUpdated) {
        setState(() {
          _errorMessage = null;
          _successMessage = 'Password reset successfully';
        });

        // Navigate back to the login screen
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()), // Replace with your login page widget
          );
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to reset password';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[800], // Dark background color
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor:
              Colors.tealAccent.withOpacity(0.5), // Teal accent color with opacity
            ),
          ),
          Positioned(
            top: 150,
            right: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Colors
                  .tealAccent.withOpacity(0.4), // Teal accent color
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: CircleAvatar(
              radius: 80,
              backgroundColor:
              Colors.tealAccent.withOpacity(0.6), // Teal accent color with opacity
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo2.png', height: 120.0),
                  SizedBox(height: 40.0),
                  if (!_isEmailEntered)
                    Form(
                      key: _formKeyEmail,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.tealAccent,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKeyEmail.currentState!.validate()) {
                                await checkEmail();
                              }
                            },
                            child: Text(
                              'Check Email',
                              style: TextStyle(
                                color: Colors.blueGrey[800],
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.tealAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_isEmailEntered && _isEmailValid)
                    Form(
                      key: _formKeyPassword,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.tealAccent,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a new password';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.tealAccent,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              } else if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKeyPassword.currentState!.validate()) {
                                await resetPassword();
                              }
                            },
                            child: Text(
                              'Reset Password',
                              style: TextStyle(
                                color: Colors.blueGrey[800],
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.tealAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_isEmailEntered && !_isEmailValid)
                    Text(
                      'Email not found',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16.0,
                      ),
                    ),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16.0,
                      ),
                    ),
                  if (_successMessage != null)
                    Text(
                      _successMessage!,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16.0,
                      ),
                    ),
                  SizedBox(height: 10.0),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Back to Login',
                      style: TextStyle(color: Colors.tealAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
