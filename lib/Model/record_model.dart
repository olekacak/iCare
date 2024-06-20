import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:icare/Controller/record_controller.dart';

class RecordModel {
  String? date;
  String? time;
  bool? fall;

  RecordModel({this.date, this.time, this.fall});

  factory RecordModel.fromJson(Map<String, dynamic> json) {
    return RecordModel(
      date: formatDate(json['date']),
      time: json['time'],
      fall: json['fall'] is bool ? json['fall'] : json['fall'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
      'fall': fall,
    };
  }

  static String formatDate(String date) {
    // Ensure the date is in the format YYYY-MM-DD
    List<String> parts = date.split('-');
    String year = parts[0];
    String month = parts[1].padLeft(2, '0');
    String day = parts[2].padLeft(2, '0');
    return '$year-$month-$day';
  }

  static Future<RecordModel?> getFallLatest() async {
    try {
      RecordController recordController = RecordController(path: "/sensor/latest");

      // Perform GET request to fetch latest fall record
      await recordController.get();

      int statusCode = recordController.status();
      if (statusCode == 200) {
        var responseData = await recordController.result();
        if (responseData != null) {
          print('Raw JSON data: $responseData');
          return RecordModel.fromJson(responseData);
        } else {
          print('Error: Response data is null');
          return null;
        }
      } else {
        print('Failed to fetch latest fall record. Status code: $statusCode');
        return null;
      }
    } catch (e) {
      print("Error fetching latest fall record: $e");
      return null;
    }
  }

  Future<bool> postFall() async {
    RecordController recordController = RecordController(path: "/sensor/postFall");
    recordController.setBody(toJson());

    try {
      await recordController.post();
      int statusCode = recordController.status();
      if (statusCode == 200) {
        Map<String, dynamic>? responseData = await recordController.result();
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
      print("Error sending fall data: $e");
      return false;
    }
  }

  static Future<List<RecordModel>> getAllFall() async {
    try {
      RecordController recordController = RecordController(path: "/sensor/getAllFall");

      // Perform GET request to fetch all fall records
      await recordController.get();

      int statusCode = recordController.status();
      if (statusCode == 200) {
        var responseData = await recordController.result();
        if (responseData != null && responseData is List) {
          // Convert each item in the list to RecordModel using fromJson
          List<RecordModel> fallRecords = responseData.map((json) => RecordModel.fromJson(json)).toList();
          return fallRecords;
        } else {
          print('Error: Response data is null or not a list');
          return [];
        }
      } else {
        print('Failed to fetch fall records. Status code: $statusCode');
        return [];
      }
    } catch (e) {
      print("Error fetching fall records: $e");
      return [];
    }
  }
}
