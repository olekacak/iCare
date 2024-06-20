import 'package:flutter/material.dart';
import 'package:icare/View/google_map.dart'; // Import your other pages as needed
import 'dart:async';
import '../Model/record_model.dart';
import 'camera.dart';
import 'dashboard.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late RecordModel _latestFallRecord;
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _latestFallRecord = RecordModel(); // Initialize with a dummy or default instance
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchLatestFall(); // Fetch initially
      // Do not cancel the timer here; it will be canceled after the initial fetch in fetchLatestFall()
    });
  }

  Future<void> fetchLatestFall() async {
    try {
      RecordModel? newData = await RecordModel.getFallLatest();
      if (newData != null) {
        // Compare newData with _latestFallRecord before updating
        if (newData.date != _latestFallRecord.date ||
            newData.time != _latestFallRecord.time ||
            newData.fall != _latestFallRecord.fall) {
          setState(() {
            _latestFallRecord = newData; // Update the latest fall record
          });
          // Post updated record to backend
          bool success = await _latestFallRecord.postFall();
          if (success) {
            print('Successfully sent updated fall record to backend');
          } else {
            print('Failed to send updated fall record to backend');
          }
        }
      }
    } catch (e) {
      print('Error fetching latest fall data: $e');
      // Handle error as per your application's requirement
    }
  }

  Future<void> getAllFallRecords() async {
    try {
      List<RecordModel> allFallRecords = await RecordModel.getAllFall();

      // Show modal bottom sheet with the list of fall records
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ListView.builder(
            itemCount: allFallRecords.length,
            itemBuilder: (context, index) {
              RecordModel record = allFallRecords[index];
              return ListTile(
                title: Text('Date: ${record.date}'),
                subtitle: Text('Time: ${record.time}'),
                trailing: Icon(
                  record.fall ?? false ? Icons.error : Icons.check_circle,
                  color: record.fall ?? false ? Colors.red : Colors.green,
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      print('Error fetching all fall records: $e');
      // Handle error as per your application's requirement
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildHomeContent(),
      GoogleMapPage(), // Replace with your actual pages
      CameraPage(),
      DashboardPage(),
    ];

    final List<String> _titles = [
      'Home',
      'Map',
      'Camera',
      'Dashboard',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: TextStyle(
            color: Colors.white, // Set the text color if needed
          ),
        ),
        backgroundColor: Colors.tealAccent, // Set the desired background color here
      ),
      body: Center(
        child: _pages[_currentIndex],
      ),
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
            icon: Icon(Icons.map),
            label: 'Map', // Change label to 'Map'
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
    );
  }

  Widget _buildHomeContent() {
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
          top: -50,
          left: -50,
          child: CircleAvatar(
            radius: 100,
            backgroundColor: Colors.tealAccent.withOpacity(0.3),
          ),
        ),
        Positioned(
          top: 150,
          right: -100,
          child: CircleAvatar(
            radius: 150,
            backgroundColor: Colors.tealAccent.withOpacity(0.3),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: CircleAvatar(
            radius: 80,
            backgroundColor: Colors.tealAccent.withOpacity(0.3),
          ),
        ),
        Positioned(
          top: 16.0,
          right: 16.0,
          child: IconButton(
            icon: Icon(Icons.history),
            onPressed: () => getAllFallRecords(),
          ),
        ),
        _latestFallRecord.date != null && _latestFallRecord.fall != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Latest Fall Record',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            Card(
              elevation: 3.0,
              margin: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: ListTile(
                title: Text(
                  'Date: ${_latestFallRecord.date}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  'Time: ${_latestFallRecord.time}',
                  style: TextStyle(
                    color: Colors.black87,
                  ),
                ),
                trailing: Icon(
                  _latestFallRecord.fall ?? false
                      ? Icons.error
                      : Icons.check_circle,
                  color: _latestFallRecord.fall ?? false
                      ? Colors.red
                      : Colors.green,
                ),
              ),
            ),
          ],
        )
            : Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA673E5)),
          ),
        ),
      ],
    );
  }
}
