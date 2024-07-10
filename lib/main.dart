import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core package
import 'package:icare/View/google_map.dart';
import 'package:icare/View/home.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'View/login.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that Flutter is initialized
  await Firebase.initializeApp(); // Initialize Firebase
  //await PermissionHandler().requestPermissions([Permission.location]);

  // Initialize SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // Set baseUrl if it's not already set
  if (!prefs.containsKey('baseUrl')) {
    prefs.setString('baseUrl', 'http://192.168.0.102:3000');
  }

  developer.log('Application started', name: 'my.app.category');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}
