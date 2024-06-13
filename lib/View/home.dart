import 'package:flutter/material.dart';
import 'package:icare/View/dashboard.dart';
import 'package:icare/View/record.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeContent(),
    RecordPage(),
    Center(child: Text('Tracker Page')), // Placeholder for Tracker
    DashboardPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _pages[_selectedIndex],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: Color(0xFFA673E5), // Light purple color
              selectedItemColor: Color(0xFFA673E5), // Light purple color for selected item
              unselectedItemColor: Colors.grey[300], // Light grey color for unselected items
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.track_changes),
                  label: 'Record', // Changed label from 'Fall Function' to 'Record'
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.track_changes),
                  label: 'Tracker',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
              ],
            ),
          ),
        ],
      ),
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
              colors: [Colors.white, Colors.pinkAccent[100]!],
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
            backgroundColor: Color(0xFFA673E5).withOpacity(0.5), // Light purple color
          ),
        ),
        Positioned(
          top: -50,
          right: -30,
          child: CircleAvatar(
            radius: 80,
            backgroundColor: Color(0xFFA673E5).withOpacity(0.5), // Light purple color
          ),
        ),
        Positioned(
          bottom: -100,
          left: -50,
          child: CircleAvatar(
            radius: 100,
            backgroundColor: Color(0xFFA673E5).withOpacity(0.5), // Light purple color
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/ali.jpg'), // Replace with actual image
              ),
              const SizedBox(height: 20),
              const Text(
                'Hello, Ali Imran',
                style: TextStyle(
                  fontSize: 24.0,
                  color: Color(0xFF6A0DAD), // Darker purple for text
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.location_pin,
                    color: Color(0xFF6A0DAD), // Darker purple for icon
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Senggarang, Batu Pahat',
                    style: TextStyle(
                      color: Color(0xFF6A0DAD), // Darker purple for text
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
