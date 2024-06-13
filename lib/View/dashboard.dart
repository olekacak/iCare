import 'package:flutter/material.dart';
import 'package:icare/View/login.dart';

class DashboardPage extends StatelessWidget {
  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (_) => false, // Clear navigation history
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Color(0xFFA673E5), // Light purple color
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFA673E5), // Light purple color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
