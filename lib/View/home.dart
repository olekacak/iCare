import 'package:flutter/material.dart';
import 'package:icare/View/camera.dart';
import 'package:icare/View/dashboard.dart';
import 'package:icare/View/record.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _tabTitles = ['Home', 'Record', 'Camera', 'Dashboard'];
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeContent(),
    RecordPage(),
    CameraPage(),
    DashboardPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null, // Remove the title from app bar
        backgroundColor: Colors.transparent, // Make the AppBar transparent
        elevation: 0, // Remove the AppBar shadow
      ),
      extendBodyBehindAppBar: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Record',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.blueGrey[800],
      ),
      extendBody: true,
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey[800]!, Colors.tealAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: -100,
          left: -50,
          child: CircleAvatar(
            radius: 100,
            backgroundColor: Colors.tealAccent.withOpacity(0.3),
          ),
        ),
        Positioned(
          top: -50,
          right: -30,
          child: CircleAvatar(
            radius: 80,
            backgroundColor: Colors.tealAccent.withOpacity(0.3),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -50,
          child: CircleAvatar(
            radius: 100,
            backgroundColor: Colors.tealAccent.withOpacity(0.3),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/ali.jpg'),
              ),
              SizedBox(height: 20),
              Text(
                'Hello, Ali Imran',
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_pin,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Senggarang, Batu Pahat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
