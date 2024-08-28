import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:icare/Controller/record_controller.dart';

import '../Controller/heartRate_controller.dart';

class HeartRateModel {
  String? heartRateId;
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
    return HeartRateModel(
      heartRateId: json['heartRateId'],
      heartRate: json['heartRate'] != null ? int.tryParse(json['heartRate']) : 0,
      date: formatDate(json['date'] ?? ''),
      time: json['time'],
      deviceId: json['mac'],
      name: json['deviceName'] ?? json['name'],
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

  static Future<HeartRateModel?> sendStartSignal() async {
    try {
      HeartRateController recordController = HeartRateController(path: "/startHeartRate");
      await recordController.postSignal();
      int statusCode = recordController.status();

      print('Response status: $statusCode');

      if (statusCode == 200) {
        var responseData = await recordController.result();
        print('Response Data: $responseData');

        if (responseData != null && responseData is Map<String, dynamic>) {
          // Handle cases where 'status' field is the only expected field
          if (responseData.containsKey('status')) {
            return HeartRateModel(status: responseData['status']);
          } else {
            print('Response does not contain expected fields: $responseData');
            return null;
          }
        } else {
          print('Invalid response format: $responseData');
          return null;
        }
      } else {
        print('Failed with status code: $statusCode');
        return null;
      }
    } catch (e) {
      print('Error sending start signal: $e');
      return null;
    }
  }



  static Future<HeartRateModel?> getLatestHeartRate() async {
    try {
      RecordController recordController = RecordController(path: "/heartRate/latest");

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
      return null;
    }
  }

  Future<bool> postHeartRate() async {
    if (_isProcessing) return false; // Prevent multiple submissions
    _isProcessing = true;

    try {
      // Create the RecordController with the endpoint for posting heart rate data
      RecordController recordController = RecordController(path: "/heartRate/postHeartRate");

      // Set the body of the request
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




  static Future<List<HeartRateModel>> getAllHeartRates() async {
    try {
      RecordController recordController = RecordController(path: "/heartRate/getAllHeartRate");

      await recordController.get();
      int statusCode = recordController.status();
      if (statusCode == 200) {
        var responseData = await recordController.result();
        if (responseData != null && responseData is List) {
          List<HeartRateModel> heartRateRecords = responseData.map((json) => HeartRateModel.fromJson(json)).toList();
          return heartRateRecords;
        } else {
          print('Error: Response data is null or not a list');
          return [];
        }
      } else {
        print('Failed to fetch heart rate records. Status code: $statusCode');
        return [];
      }
    } catch (e) {
      print("Error fetching heart rate records: $e");
      return [];
    }
  }
}
