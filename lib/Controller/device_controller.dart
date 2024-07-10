// Controller (SignUpController)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DeviceController {
  String path;
  http.Response? _res;
  final Map<String, dynamic> _body = {};
  final Map<String, String> _headers = {};
  dynamic _resultData;

  DeviceController({required this.path});

  setBody(Map<String, dynamic> data) {
    _body.clear();
    _body.addAll(data);
    _headers["Content-Type"] = "application/json; charset=UTF-8";
  }

  Future<String> getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('baseUrl') ?? '';
  }

  Future<void> post() async {
    String baseUrl = await getBaseUrl();
    _res = await http.post(
      Uri.parse(baseUrl + path),
      headers: _headers,
      body: jsonEncode(_body),
    );
    _parseResult();
  }

  Future<void> get() async {
    String baseUrl = await getBaseUrl();
    _res = await http.get(
      Uri.parse(baseUrl + path),
      headers: _headers,
    );
    _parseResult();
  }

  void _parseResult() {
    try {
      print("raw response: ${_res?.body}");
      _resultData = jsonDecode(_res?.body ?? "");
    } catch (ex) {
      _resultData = _res?.body;
      print("exception in http result parsing ${ex}");
    }
  }

  dynamic result() {
    return _resultData;
  }

  int status() {
    return _res?.statusCode ?? 0;
  }
}
