import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Model/record_model.dart';
import 'camera.dart';
import 'dashboard.dart';
import 'google_map.dart';
import 'heartRate.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RecordModel _latestFallRecord = RecordModel(
    date: '',
    time: '',
    fall: false,
    deviceId: '',
    location: '',
  );
  Timer? _timer;
  int _currentIndex = 0;
  LatLng _mapDestination = LatLng(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    fetchLatestFall(); // Fetch initially
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchLatestFall(); // Fetch periodically
    });
  }

  Future<void> fetchLatestFall() async {
    try {
      RecordModel? newData = await RecordModel.getFallLatest();
      if (newData != null) {
        // Validate the newData
        if (newData.date != null && newData.time != null && newData.deviceId != null) {
          // Compare newData with _latestFallRecord before updating
          if (newData.date != _latestFallRecord.date ||
              newData.time != _latestFallRecord.time ||
              newData.fall != _latestFallRecord.fall ||
              newData.deviceId != _latestFallRecord.deviceId ||
              newData.name != _latestFallRecord.name ||
              newData.location != _latestFallRecord.location) {
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
        } else {
          print('Received data is missing required fields.');
        }
      }
    } catch (e) {
      print('Error fetching latest fall data: $e');
      // Optionally show a dialog or notification to the user about the error
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
                subtitle: FutureBuilder<String>(
                  future: _getLocationString(record.location),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading...');
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Text(
                        'Time: ${record.time}\nDevice ID: ${record.deviceId}\nName: ${record.name ?? 'Unknown'}\nLocation: ${snapshot.data}',
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      );
                    }
                  },
                ),
                trailing: Icon(
                  record.fall ?? false ? Icons.error : Icons.check_circle,
                  color: record.fall ?? false ? Colors.red : Colors.green,
                ),
                onTap: () {
                  LatLng destination = LatLng(
                    double.parse(record.location!['lat'].toString()),
                    double.parse(record.location!['lon'].toString()),
                  );
                  _navigateToMap(destination);
                },
              );
            },
          );
        },
      );
    } catch (e) {
      print('Error fetching all fall records: $e');
      // Optionally show a dialog or notification to the user about the error
    }
  }

  Future<String> _getLocationString(dynamic location) async {
    if (location is String) {
      // Parse the string to extract lat and lon
      List<String> parts = location.split(',');
      if (parts.length == 2) {
        try {
          double lat = double.parse(parts[0].trim().split(':')[1]);
          double lon = double.parse(parts[1].trim().split(':')[1]);
          location = {'lat': lat, 'lon': lon};
        } catch (e) {
          print('Error parsing lat lon from string: $e');
          return 'Error parsing lat lon from string';
        }
      } else {
        return 'Invalid location format';
      }
    }

    if (location is Map<String, dynamic>) {
      double lat = location['lat'];
      double lon = location['lon'];

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
        if (placemarks != null && placemarks.isNotEmpty) {
          Placemark placemark = placemarks[0];
          String address = '${placemark.name ?? ''}, '
              '${placemark.subLocality ?? ''}, '
              '${placemark.locality ?? ''}, '
              '${placemark.postalCode ?? ''}, '
              '${placemark.country ?? ''}';
          return address.trim();
        } else {
          return 'No address found'; // Handle no results case
        }
      } catch (e) {
        print('Error getting location from coordinates: $e');
        return 'Error fetching address'; // Handle geocoding error
      }
    }

    return 'Unknown location'; // Handle unexpected cases
  }

  void _navigateToMap(LatLng destination) {
    setState(() {
      _mapDestination = destination;
      //print("destination is {$destination}");
      _currentIndex = 1; // Switch to the Map tab
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildHomeContent(),
      HeartRatePage(),
      GoogleMapPage(destination: _mapDestination),
      CameraPage(),
      DashboardPage(),
    ];

    final List<String> _titles = [
      'Home',
      'Heart Rate',
      'Map',
      'Camera',
      'Dashboard',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            _titles[_currentIndex],
            style: TextStyle(
              color: Colors.white, // Set the text color if needed
            ),
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
            icon: Icon(Icons.favorite),
            label: 'Heart Rate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
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
            ? GestureDetector(
          onTap: () {
            // Navigate to GoogleMapPage when the latest fall record is tapped
            LatLng destination = LatLng(
              double.parse(_latestFallRecord.location.split(',')[0].split(':')[1].trim()), // Parse latitude from location string
              double.parse(_latestFallRecord.location.split(',')[1].split(':')[1].trim()), // Parse longitude from location string
            );
            _navigateToMap(destination);
          },
          child: Column(
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
                  subtitle: FutureBuilder<String>(
                    future: _getLocationString(_latestFallRecord.location),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading...'); // Placeholder while fetching
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Text(
                          'Time: ${_latestFallRecord.time}\nDevice ID: ${_latestFallRecord.deviceId}\nName: ${_latestFallRecord.name}\nLocation: ${snapshot.data}',
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        );
                      }
                    },
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
          ),
        )
            : Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent),
          ),
        ),
      ],
    );
  }
}