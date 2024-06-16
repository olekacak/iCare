import 'package:flutter/material.dart';
import 'dart:async';

import '../Controller/record_controller.dart';
import '../Model/record_model.dart';

class RecordPage extends StatefulWidget {
  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late RecordController _recordController;
  late List<RecordModel> _fallRecords;
  Timer? _timer;
  String? _lastFetchedDataString;

  @override
  void initState() {
    super.initState();
    _recordController = RecordController();
    _fallRecords = [];
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchSensorData();
    });
  }

  Future<void> fetchSensorData() async {
    final newData = await _recordController.fetchSensorData();
    if (newData != null) {
      final newDataString = '${newData['date']}${newData['fall']}';
      if (newDataString != _lastFetchedDataString &&
          newData['date'] != null &&
          newData['fall'] != null) {
        final record = RecordModel.fromJson(newData);
        setState(() {
          _fallRecords.add(record);
          _lastFetchedDataString = newDataString;
        });
        await _recordController.sendFallData(record); // Send data to backend
      }
    }
  }

  void _showFallRecords(BuildContext context) async {
    try {
      List<RecordModel> historicalRecords =
      await _recordController.fetchSensorDataFromBackend();

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Historical Fall Records',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Text color
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.0),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: historicalRecords.length,
                    itemBuilder: (context, index) {
                      final record = historicalRecords[index];
                      return ListTile(
                        title: Text(
                          'Date: ${record.date}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Fall Detected: ${record.fall ?? false ? 'Yes' : 'No'}',
                        ),
                        trailing: Icon(
                          record.fall ?? false ? Icons.error : Icons.check_circle,
                          color: record.fall ?? false ? Colors.red : Colors.green,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('Error fetching historical sensor data: $e');
      // Handle error as per your application's requirement
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => _showFallRecords(context),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
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
              backgroundColor: Colors.tealAccent.withOpacity(0.3), // Light purple color with opacity
            ),
          ),
          Positioned(
            top: 150,
            right: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Colors.tealAccent.withOpacity(0.3), // Light purple color with opacity
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.tealAccent.withOpacity(0.3), // Light purple color with opacity
            ),
          ),
          _fallRecords.isEmpty
              ? Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA673E5)),
            ),
          )
              : ListView.builder(
            itemCount: _fallRecords.length,
            itemBuilder: (context, index) {
              final record = _fallRecords[index];
              return Card(
                elevation: 3.0,
                margin: EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: ListTile(
                  title: Text(
                    'Date: ${record.date}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Text color
                    ),
                  ),
                  subtitle: Text(
                    'Fall Detected: ${record.fall ?? false ? 'Yes' : 'No'}',
                    style: TextStyle(
                      color: Colors.black87, // Text color
                    ),
                  ),
                  trailing: Icon(
                    record.fall ?? false ? Icons.error : Icons.check_circle,
                    color: record.fall ?? false ? Colors.red : Colors.green,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
