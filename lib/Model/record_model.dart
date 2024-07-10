import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:icare/Controller/record_controller.dart';

class RecordModel {
  String? date;
  String? time;
  bool? fall;
  String? deviceId;
  final dynamic location;
  int? fallId;

  RecordModel({this.date, this.time, this.fall, this.deviceId, this.location, this.fallId});

  factory RecordModel.fromJson(Map<String, dynamic> json) {
    return RecordModel(
      date: formatDate(json['date']),
      time: json['time'],
      fall: json['fall'] is bool ? json['fall'] : json['fall'] == 'true',
      deviceId: json['deviceId'],
      location: json['location'],
      fallId: json['fallId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
      'fall': fall,
      'deviceId': deviceId,
      'location': location,
      'fallId': fallId,
    };
  }

  static String formatDate(String date) {
    List<String> parts = date.split('-');
    String year = parts[0];
    String month = parts[1].padLeft(2, '0');
    String day = parts[2].padLeft(2, '0');
    return '$year-$month-$day';
  }

  static Future<RecordModel?> getFallLatest() async {
    try {
      RecordController recordController = RecordController(path: "/sensor/latest");

      await recordController.get();
      int statusCode = recordController.status();
      if (statusCode == 200) {
        var responseData = await recordController.result();
        if (responseData != null) {
          return RecordModel.fromJson(responseData);
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

  Future<bool> postFall() async {
    RecordController recordController = RecordController(path: "/sensor/postFall");
    recordController.setBody(toJson());

    print('Sending JSON body: ${json.encode(toJson())}');

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

      await recordController.get();
      int statusCode = recordController.status();
      if (statusCode == 200) {
        var responseData = await recordController.result();
        if (responseData != null && responseData is List) {
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
