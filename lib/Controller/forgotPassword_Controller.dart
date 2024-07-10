import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordController {
  String path;
  http.Response? _res;
  final Map<String, dynamic> _body = {};
  final Map<String, String> _headers = {};
  dynamic _resultData;

  ForgotPasswordController({required this.path});

  void setBody(Map<String, dynamic> data) {
    _body.clear();
    _body.addAll(data);
    _headers["Content-Type"] = "application/json; charset=UTF-8";
  }

  Future<String> getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('baseUrl') ?? '';
  }

  Future<void> put() async {
    String baseUrl = await getBaseUrl();
    _res = await http.put(
      Uri.parse(baseUrl + path),
      headers: _headers,
      body: jsonEncode(_body),
    );
    _parseResult();
  }

  void _parseResult() {
    try {
      _resultData = jsonDecode(_res?.body ?? "");
    } catch (ex) {
      _resultData = _res?.body;
      print("Exception in HTTP result parsing: $ex");
    }
  }

  dynamic result() {
    return _resultData;
  }

  int status() {
    return _res?.statusCode ?? 0;
  }
}
