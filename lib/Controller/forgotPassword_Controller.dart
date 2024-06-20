import 'dart:convert';
import 'package:http/http.dart' as http;

class ForgotPasswordController {
  final String baseUrl = 'http://10.131.76.206:3000'; // Replace with your backend URL
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

  Future<void> put() async {
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
