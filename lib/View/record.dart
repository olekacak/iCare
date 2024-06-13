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
      final newDataString = newData['date'].toString() + newData['fall'].toString();
      if (newDataString != _lastFetchedDataString && newData['date'] != null && newData['fall'] != null) {
        final record = RecordModel.fromJson(newData);
        setState(() {
          _fallRecords.add(record);
          _lastFetchedDataString = newDataString;
        });
        await _recordController.sendFallData(record);  // Send data to backend
      }
    }
  }


  void _showFallRecords(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          child: ListView.builder(
            itemCount: _fallRecords.length,
            itemBuilder: (context, index) {
              final record = _fallRecords[index];
              return ListTile(
                title: Text('Date: ${record.date}'),
                subtitle: Text('Fall Detected: ${record.fall}'),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Data Records'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => _showFallRecords(context),
          ),
        ],
      ),
      body: _fallRecords.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _fallRecords.length,
        itemBuilder: (context, index) {
          final record = _fallRecords[index];
          return ListTile(
            title: Text('Date: ${record.date}'),
            subtitle: Text('Fall Detected: ${record.fall}'),
          );
        },
      ),
    );
  }
}