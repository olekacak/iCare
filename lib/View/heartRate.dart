import 'dart:async';
import 'package:flutter/material.dart';
import '../Model/heartRate_model.dart';

class HeartRatePage extends StatefulWidget {
  @override
  _HeartRatePageState createState() => _HeartRatePageState();
}

class _HeartRatePageState extends State<HeartRatePage> {
  int _heartRate = 0;
  String _lastUpdateTime = "Loading...";
  bool _isProcessing = false;
  bool _isHeartRatePosted = false; // Add this flag

  @override
  void initState() {
    super.initState();
  }

  void _sendStartSignal() async {
    if (_isProcessing) return; // Prevent multiple requests

    setState(() {
      _isProcessing = true;
      _isHeartRatePosted = false; // Reset flag
    });

    try {
      print("Sending start signal...");
      HeartRateModel? heartRateModel = await HeartRateModel.sendStartSignal();
      print("Received start signal response: ${heartRateModel?.status}");

      if (heartRateModel != null && heartRateModel.status == 'Heart rate detection started') {
        setState(() {
          _heartRate = 0;
          _lastUpdateTime = heartRateModel.status;
        });

        // Wait 20 seconds for heart rate measurement
        await Future.delayed(Duration(seconds: 20));

        // Fetch latest heart rate data
        HeartRateModel? latestHeartRate = await HeartRateModel.getLatestHeartRate();
        print("Received latest heart rate response: ${latestHeartRate?.heartRate}");

        if (latestHeartRate != null) {
          setState(() {
            _heartRate = latestHeartRate.heartRate ?? 0;
            _lastUpdateTime = latestHeartRate.time ?? 'No data';
          });

          // Only send the heart rate data if it hasn't been posted yet
          if (!_isHeartRatePosted) {
            bool success = await latestHeartRate.postHeartRate();
            if (success) {
              print('Heart rate data successfully sent to backend');
              _isHeartRatePosted = true; // Mark as posted
            } else {
              print('Failed to send heart rate data to backend');
            }
          }
        } else {
          print('No heart rate data received');
        }
      } else {
        print('Error starting heart rate detection: ${heartRateModel?.status}');
      }
    } catch (e) {
      print('Error during heart rate measurement: $e');
    } finally {
      // Ensure this runs regardless of success or failure
      setState(() {
        _isProcessing = false; // Allow new request
      });
    }
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
                    height: MediaQuery.of(context).size.height,
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
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 100,
                        color: Colors.red,
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
                        onPressed: _isProcessing ? null : _sendStartSignal,
                        child: _isProcessing
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Start Heart Rate Measurement'),
                      ),
                      _buildHeartRateChart(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateChart() {
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
                          '42',
                          style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'BPM',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Text(
                      'at 3:45 pm',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
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
                          '121',
                          style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'BPM',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Text(
                      'at 2:08 pm',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
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
}

class MountainTrailClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Increase this value to move the mountain trail higher
    double verticalOffset = 150.0; // Increased value to move trail higher

    List<Offset> points = [
      Offset(0, size.height - 150 - verticalOffset),
      Offset(size.width * 0.1, size.height - 200 - verticalOffset),
      Offset(size.width * 0.2, size.height - 170 - verticalOffset),
      Offset(size.width * 0.3, size.height - 220 - verticalOffset),
      Offset(size.width * 0.4, size.height - 180 - verticalOffset),
      Offset(size.width * 0.5, size.height - 200 - verticalOffset),
      Offset(size.width * 0.6, size.height - 150 - verticalOffset),
      Offset(size.width * 0.7, size.height - 190 - verticalOffset),
      Offset(size.width * 0.8, size.height - 160 - verticalOffset),
      Offset(size.width, size.height - 150 - verticalOffset),
    ];

    if (points.isNotEmpty) {
      // Move to the first point
      path.moveTo(points[0].dx, points[0].dy);

      // Draw a smooth curve through all the points
      for (int i = 1; i < points.length; i++) {
        Offset prevPoint = points[i - 1];
        Offset currentPoint = points[i];

        // Use quadratic Bezier curve for smoothness
        path.quadraticBezierTo(
          (prevPoint.dx + currentPoint.dx) / 2, // Control point x
          (prevPoint.dy + currentPoint.dy) / 2, // Control point y
          currentPoint.dx, // End point x
          currentPoint.dy, // End point y
        );
      }
    }

    // Close the path to clip the area below the mountain trail line
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class HeartRateChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    Path linePath = Path();

    // Start the path at the left bottom corner
    linePath.moveTo(0, size.height - 10); // Adjust 10 to change the line's vertical position

    // Draw a straight line across the width of the screen
    linePath.lineTo(size.width, size.height - 10); // Adjust 10 to change the line's vertical position

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
