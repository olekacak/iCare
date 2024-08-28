import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Implement background task to check stream status or any periodic work
    // You might want to call a method that checks the camera stream status
    print('Background task executed: $task');
    return Future.value(true);
  });
}

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final Map<String, String> _cameraUrls = {
    'Camera 1': 'http://192.168.137.235/stream',
    'Camera 2': 'http://192.168.137.235', // Replace with actual URL
  };
  String selectedCamera = 'Camera 1';
  String proxyUrl = '';
  bool _hasError = false;
  Timer? _errorCheckTimer;

  @override
  void initState() {
    super.initState();
    _updateCameraUrl(selectedCamera);
    _startErrorCheck();
    Workmanager().initialize(callbackDispatcher);
    Workmanager().registerPeriodicTask(
      '1',
      'checkStreamStatus',
      frequency: Duration(minutes: 15), // Adjust frequency as needed
    );
  }

  void _updateCameraUrl(String camera) {
    setState(() {
      proxyUrl = _cameraUrls[camera] ?? '';
      print('Updated URL to: $proxyUrl');
      _hasError = false;
    });
  }

  void _startErrorCheck() {
    _errorCheckTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _checkStreamStatus();
    });
  }

  Future<void> _checkStreamStatus() async {
    const int maxRetries = 3;
    const Duration retryDelay = Duration(seconds: 5);
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        print('Checking stream status for: $proxyUrl');
        final response = await http
            .get(Uri.parse(proxyUrl))
            .timeout(Duration(seconds: 30));

        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}'); // Log the response body

        if (response.statusCode == 200) {
          setState(() {
            _hasError = false;
          });
          return;
        } else {
          setState(() {
            _hasError = true;
          });
        }
      } catch (e) {
        print('Error checking stream status: $e');
        setState(() {
          _hasError = true;
        });
      }

      retryCount++;
      await Future.delayed(retryDelay);
    }
  }

  @override
  void dispose() {
    _errorCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: null,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[800]!, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                value: selectedCamera,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCamera = newValue!;
                    _updateCameraUrl(selectedCamera);
                    _hasError = false;
                  });
                },
                items: _cameraUrls.keys.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: Colors.blueGrey[800]!,
                      ),
                    ),
                  );
                }).toList(),
                dropdownColor: Colors.tealAccent,
              ),
            ),
            Expanded(
              child: Center(
                child: _hasError
                    ? Text(
                  'Error loading stream',
                  style: TextStyle(color: Colors.white),
                )
                    : Mjpeg(
                  stream: proxyUrl,
                  isLive: true,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
