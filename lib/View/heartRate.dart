import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/heartRate_model.dart';
import 'package:flutter/scheduler.dart';

class HeartRatePage extends StatefulWidget {
  @override
  _HeartRatePageState createState() => _HeartRatePageState();
}

class _HeartRatePageState extends State<HeartRatePage> with SingleTickerProviderStateMixin {
  int _heartRate = 0;
  String _lastUpdateTime = "Loading...";
  bool _isProcessing = false;
  bool _isHeartRatePosted = false;
  String? _selectedDeviceId;
  Map<String, String> _deviceMap = {}; // Map to hold device ID and names
  Map<String, int> _deviceHeartRates = {};
  Map<String, String> _deviceUpdateTimes = {};
  bool _canMeasure = true; // Add state to manage measurement availability
  late AnimationController _animationController;
  late Animation<double> _blinkAnimation;
  int _minHeartRate = 0;
  int _maxHeartRate = 0;
  int _avgHeartRate = 0;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController and Tween
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )
      ..repeat(reverse: true);

    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Load device IDs and names from shared preferences
    _loadDeviceData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _fetchAndProcessHeartRateData() async {
    if (_selectedDeviceId == null) {
      print("No device selected");
      return;
    }

    try {
      // Fetch all heart rate data for today
      DateTime now = DateTime.now();
      String today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now
          .day.toString().padLeft(2, '0')}';

      List<HeartRateModel> heartRates = await HeartRateModel.getAllHeartRates(
          deviceId: _selectedDeviceId!);

      // Filter records to include only today's data
      List<HeartRateModel> todayHeartRates = heartRates.where((e) =>
      e.date == today).toList();

      if (todayHeartRates.isNotEmpty) {
        int minHeartRate = todayHeartRates.map((e) => e.heartRate ?? 0).reduce((
            a, b) => a < b ? a : b);
        int maxHeartRate = todayHeartRates.map((e) => e.heartRate ?? 0).reduce((
            a, b) => a > b ? a : b);
        double avgHeartRate = todayHeartRates.map((e) => e.heartRate ?? 0)
            .reduce((a, b) => a + b) / todayHeartRates.length;

        setState(() {
          _minHeartRate = minHeartRate;
          _maxHeartRate = maxHeartRate;
          _avgHeartRate = avgHeartRate.round(); // Round to the nearest integer
        });
      } else {
        // No data for today
        setState(() {
          _minHeartRate = 0;
          _maxHeartRate = 0;
          _avgHeartRate = 0;
        });
      }
    } catch (e) {
      print('Error fetching heart rate data: $e');
      // Handle error case here
    }
  }


  void _loadDeviceData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? deviceId = prefs.getStringList('deviceId');
    List<String>? deviceName = prefs.getStringList('deviceName');

    setState(() {
      if (deviceId != null && deviceName != null &&
          deviceId.length == deviceName.length) {
        _deviceMap = Map.fromIterables(deviceId, deviceName);
      } else {
        _deviceMap = {};
      }
    });
  }

  void _startHeartRateMeasurement() async {
    if (!_canMeasure || _isProcessing || _selectedDeviceId == null) {
      print('Measurement start condition not met.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _isHeartRatePosted = false;
      _canMeasure = false; // Disable the button until measurement is complete
    });

    try {
      print("Sending start signal to $_selectedDeviceId...");
      HeartRateModel? heartRateModel = await HeartRateModel.sendStartSignal(
          deviceId: _selectedDeviceId);

      if (heartRateModel != null &&
          heartRateModel.status == 'Heart rate detection started') {
        Timer.periodic(Duration(seconds: 2), (timer) async {
          try {
            HeartRateModel? latestHeartRate = await HeartRateModel
                .getLatestHeartRate(deviceId: _selectedDeviceId);
            if (latestHeartRate != null && latestHeartRate.heartRate != null) {
              if (latestHeartRate.deviceId == _selectedDeviceId) {
                setState(() {
                  _deviceHeartRates[_selectedDeviceId!] =
                  latestHeartRate.heartRate!;
                  _deviceUpdateTimes[_selectedDeviceId!] =
                  '${latestHeartRate.date} ${latestHeartRate.time}';
                  _heartRate = latestHeartRate.heartRate!;
                  _lastUpdateTime =
                  '${latestHeartRate.date} ${latestHeartRate.time}';
                });

                timer.cancel(); // Stop the timer once we have the heart rate

                // Post the heart rate data to the backend
                HeartRateModel heartRateToPost = HeartRateModel(
                  heartRateId: null,
                  // ID will be generated by the backend
                  heartRate: _heartRate,
                  date: latestHeartRate.date,
                  time: latestHeartRate.time,
                  deviceId: _selectedDeviceId,
                  name: _deviceMap[_selectedDeviceId],
                  status: 'Posted',
                );
                bool success = await heartRateToPost.postHeartRate();
                if (success) {
                  setState(() {
                    _isHeartRatePosted = true;
                  });
                  print('Heart rate data posted successfully');
                  _fetchAndProcessHeartRateData();
                } else {
                  print('Failed to post heart rate data');
                }
              }
            }
          } catch (e) {
            print('Error getting latest heart rate: $e');
          }
        });

        // Wait for 18 seconds before allowing another measurement
        await Future.delayed(Duration(seconds: 18));
      } else {
        print(
            'Failed to start heart rate detection: ${heartRateModel?.status}');
      }
    } catch (e) {
      print('Error during heart rate measurement: $e');
    } finally {
      setState(() {
        _isProcessing = false;
        _canMeasure = true; // Re-enable the button after 18 seconds
      });
      _animationController.stop();
    }
  }

  void _onDeviceSelected(String? newValue) {
    setState(() {
      _selectedDeviceId = newValue;
      if (_selectedDeviceId != null) {
        _fetchAndProcessHeartRateData(); // Fetch and process data when a device is selected
      }
      if (_deviceHeartRates.containsKey(newValue)) {
        _heartRate = _deviceHeartRates[newValue]!;
        _lastUpdateTime = _deviceUpdateTimes[newValue]!;
      } else {
        _heartRate = 0;
        _lastUpdateTime = "Loading...";
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.tealAccent[400]!,
                    Colors.tealAccent[700]!,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Stack(
              children: [
                ClipPath(
                  clipper: MountainTrailClipper(),
                  child: Container(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueGrey[800]!, Colors.tealAccent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: HeartRateChartPainter(),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Device selection dropdown
                        DropdownButton<String>(
                          value: _selectedDeviceId,
                          items: _deviceMap.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key, // Device ID
                              child: Text(entry.value), // Device Name
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            _onDeviceSelected(newValue);
                          },
                        ),
                        SizedBox(height: 20),
                        AnimatedBuilder(
                          animation: _blinkAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _isProcessing
                                  ? _blinkAnimation.value
                                  : 1.0,
                              child: child,
                            );
                          },
                          child: Icon(
                            Icons.favorite,
                            size: 100,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '$_heartRate BPM',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _lastUpdateTime,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 50),
                        ElevatedButton(
                          onPressed: !_canMeasure || _isProcessing
                              ? null
                              : _startHeartRateMeasurement,
                          child: _isProcessing
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Measure'),
                        ),
                        _buildHeartRateChart(
                            _minHeartRate, _maxHeartRate, _avgHeartRate),
                        // Pass the values here
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Modify _buildHeartRateChart to accept parameters
Widget _buildHeartRateChart(int minHeartRate, int maxHeartRate, int avgHeartRate) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 0.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 100,
          child: CustomPaint(
            painter: HeartRateChartPainter(),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'MIN',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$minHeartRate',
                        style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'BPM',
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'MAX',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$maxHeartRate',
                        style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'BPM',
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'AVG',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$avgHeartRate',
                        style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'BPM',
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// Custom Clipper
class MountainTrailClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.5);
    path.lineTo(size.width * 0.4, size.height * 0.7);
    path.lineTo(size.width * 0.8, size.height * 0.6);
    path.lineTo(size.width, size.height * 0.7);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

// Custom Painter
class HeartRateChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Path path = Path();
    double waveHeight = size.height / 2;
    double frequency = 2.0; // Higher frequency for more peaks

    path.moveTo(0, waveHeight);

    for (double i = 0; i <= size.width; i += 10) {
      path.lineTo(i, waveHeight + 30 * (i % (size.width / frequency) > size.width / (2 * frequency) ? 1 : -1));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
