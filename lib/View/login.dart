import 'package:flutter/material.dart';
import '../View/home.dart';
import '../View/signup.dart';
import '../Model/login_model.dart';
import 'forgotPasword.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true; // Variable to control password visibility
  String? _errorMessage; // Variable to hold the error message
  int _failedAttempts = 0; // Counter to track failed login attempts

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[800]!, // Dark background color
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.tealAccent.withOpacity(0.5), // Teal accent color with opacity
            ),
          ),
          Positioned(
            top: 150,
            right: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Colors.tealAccent.withOpacity(0.4), // Teal accent color
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.tealAccent.withOpacity(0.6), // Teal accent color with opacity
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo2.png', height: 120.0), // Replace with your logo
                  SizedBox(height: 40.0),
                  if (_errorMessage != null) // Display error message if not null
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16.0,
                      ),
                    ),
                  SizedBox(height: 20.0),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10.0,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
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
                                color: Colors.tealAccent, // Teal accent color
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
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.tealAccent, // Teal accent color
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.tealAccent, // Teal accent color
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                String email = _emailController.text;
                                String password = _passwordController.text;

                                try {
                                  LoginModel loginModel = LoginModel(email: email, password: password);
                                  bool loggedIn = await loginModel.login();
                                  if (loggedIn) {
                                    _emailController.clear();
                                    _passwordController.clear();
                                    setState(() {
                                      _errorMessage = null;
                                      _failedAttempts = 0; // Reset failed attempts on successful login
                                    });
                                    // Navigate to Home page after successful login
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => HomePage()),
                                    );
                                  } else {
                                    setState(() {
                                      _errorMessage = 'Invalid email or password';
                                      _failedAttempts++; // Increment failed attempts on failed login
                                    });
                                  }
                                } catch (e) {
                                  setState(() {
                                    _errorMessage = 'Failed to login. Please try again later.';
                                  });
                                }
                              }
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.blueGrey[800]!, // Dark background color
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.tealAccent, // Teal accent color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_failedAttempts >= 3) // Display "Forgot Password" button after 3 failed attempts
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.tealAccent), // Teal accent color
                      ),
                    ),
                  SizedBox(height: 10.0),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: Text(
                      'Don\'t have an account? Sign up',
                      style: TextStyle(color: Colors.tealAccent), // Teal accent color
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
