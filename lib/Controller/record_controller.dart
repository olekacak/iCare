import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Model/record_model.dart';

class RecordController {
  final String baseUrl = 'http://192.168.0.122:3000';

  Future<Map<String, dynamic>?> fetchSensorData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sensor'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load sensor data');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> sendFallData(RecordModel record) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.122:3000/sensor/store'),  // Ensure this matches your server's route
        headers: {'Content-Type': 'application/json'},
        body: json.encode(record.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send fall data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<RecordModel>> fetchSensorDataFromBackend() async {
    try {
      final url = Uri.parse('$baseUrl/sensor/firebase');  // Adjust the endpoint to your backend's route
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => RecordModel.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }
}
