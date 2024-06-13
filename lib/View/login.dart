import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:icare/View/home.dart';
import 'package:icare/View/signup.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage; // Variable to hold the error message

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Light grey background color
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Color(0xFFA673E5).withOpacity(0.5), // Light purple color
            ),
          ),
          Positioned(
            top: 150,
            right: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Color(0xFFA673E5), // Light purple color
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Color(0xFFA673E5).withOpacity(0.5), // Light purple color
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', height: 120.0), // Replaced the text with the logo
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
                              labelText: 'Username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              fillColor: Colors.white,
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
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              fillColor: Colors.white,
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
                                  final UserCredential userCredential =
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                    email: email,
                                    password: password,
                                  );
                                  _emailController.clear();
                                  _passwordController.clear();
                                  // Navigate to Home page after successful login
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => HomePage()),
                                  );
                                } on FirebaseAuthException catch (e) {
                                  setState(() {
                                    _errorMessage = 'Invalid email or password';
                                  });
                                }
                              }
                            },
                            child: Text('Login'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFA673E5), // Light purple color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                      style: TextStyle(color: Color(0xFFA673E5)), // Light purple color
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
