import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:icare/Controller/record_controller.dart';

import '../Controller/heartRate_controller.dart';

class HeartRateModel {
  int? heartRateId;
  int? heartRate;
  String? date;
  String? time;
  String? deviceId;
  String? name;
  final String status;
  static bool _isProcessing = false;


  HeartRateModel({
    this.heartRateId,
    this.heartRate,
    this.date,
    this.time,
    this.deviceId,
    this.name,
    required this.status,
  });

  factory HeartRateModel.fromJson(Map<String, dynamic> json) {
    print('JSON data received: $json'); // Debugging output

    return HeartRateModel(
      heartRateId: json['heartRateId'] as int? ?? 0,
      heartRate: json['heartRate'] as int? ?? 0,
      date: formatDate(json['date'] ?? ''),
      time: json['time'] as String? ?? '',
      deviceId: json['mac'] as String? ?? '',
      name: json['deviceName'] ?? json['name'] ?? '',
      status: json['status'] ?? 'Unknown',
    );
  }



  Map<String, dynamic> toJson() {
    return {
      'heartRateId': heartRateId,
      'heartRate': heartRate,
      'date': date,
      'time': time,
      'deviceId': deviceId,
      'deviceName': name, // Use 'deviceName' for consistency
    };
  }

  static String formatDate(String date) {
    List<String> parts = date.split('-');
    String year = parts[0];
    String month = parts[1].padLeft(2, '0');
    String day = parts[2].padLeft(2, '0');
    return '$year-$month-$day';
  }

  // Method to send the start signal
  static Future<HeartRateModel?> sendStartSignal({required String? deviceId}) async {
    try {
      // Simulate an HTTP request to send the start signal to the device
      HeartRateController recordController = HeartRateController(path: "/startHeartRate");
      recordController.setBody({'deviceId': deviceId});
      await recordController.postSignal();
      int statusCode = recordController.status();

      print('Response status: $statusCode');
      if (statusCode == 200) {
        var responseData = await recordController.result();
        print('Response Data: $responseData');
        if (responseData != null && responseData is Map<String, dynamic>) {
          if (responseData.containsKey('status')) {
            return HeartRateModel(
              status: responseData['status'],
              heartRateId: responseData['heartRateId'],
              heartRate: responseData['heartRate'],
              date: responseData['date'],
              time: responseData['time'],
              deviceId: deviceId,
              name: responseData['name'],
            );
          }
        }
      }
    } catch (e) {
      print('Error sending start signal: $e');
    }
    return null;
  }


  static Future<HeartRateModel?> getLatestHeartRate({required String? deviceId}) async {
    try {
      final String url = "/heartRate/latest?deviceId=$deviceId";
      RecordController recordController = RecordController(path: url);

      await recordController.get();
      int statusCode = recordController.status();
      if (statusCode == 200) {
        var responseData = await recordController.result();
        if (responseData != null) {
          return HeartRateModel.fromJson(responseData);
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting latest heart rate: $e');
      return null;
    }
  }


  Future<bool> postHeartRate() async {
    if (_isProcessing) return false; // Prevent multiple submissions
    _isProcessing = true;

    try {
      // Create the RecordController with the endpoint for posting heart rate data
      RecordController recordController = RecordController(path: "/heartRate/postHeartRate");

      // Set the body of the request with deviceId included
      recordController.setBody(toJson());

      // Print the JSON body for debugging
      print('Sending JSON body: ${json.encode(toJson())}');

      // Send the POST request
      await recordController.post();
      int statusCode = recordController.status();
      print('HTTP Status Code: $statusCode');

      // Check if the request was successful
      if (statusCode == 200) {
        Map<String, dynamic>? responseData = await recordController.result();
        print('Response Data: $responseData');
        if (responseData != null) {
          return true;
        } else {
          print('Error: Response data is null');
          return false;
        }
      } else {
        print('Error: HTTP status code $statusCode');
        return false;
      }
    } catch (e) {
      print("Error sending heart rate data: $e");
      return false;
    } finally {
      _isProcessing = false; // Reset the flag after processing
    }
  }

  static Future<List<HeartRateModel>> getAllHeartRates({required String deviceId}) async {
    try {
      final String url = "/heartRate/getAllHeartRate?deviceId=$deviceId";
      RecordController recordController = RecordController(path: url);

      await recordController.get();
      int statusCode = recordController.status();
      if (statusCode == 200) {
        var responseData = await recordController.result();
        print('Response Data: $responseData'); // Debugging output

        if (responseData != null && responseData is List) {
          // Ensure that each item in the list is a map and then create HeartRateModel objects
          List<HeartRateModel> heartRates = responseData
              .where((item) => item is Map<String, dynamic>) // Filter out items that are not maps
              .map((item) => HeartRateModel.fromJson(item as Map<String, dynamic>)) // Convert to HeartRateModel
              .toList();
          return heartRates;
        } else {
          print('Response Data is not a List or is null.');
          return [];
        }
      } else {
        print('Error: HTTP status code $statusCode');
        return [];
      }
    } catch (e) {
      print('Error getting heart rate records: $e');
      return [];
    }
  }

}
