import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginController {
  final String baseUrl = 'http://192.168.0.122:3000';
  String path;
  http.Response? _res;
  final Map<String, dynamic> _body = {};
  final Map<String, String> _headers = {};
  dynamic _resultData;

  LoginController({required this.path});

  setBody(Map<String, dynamic> data) {
    _body.clear();
    _body.addAll(data);
    _headers["Content-Type"] = "application/json; charset=UTF-8";
  }

  Future<void> post() async {
    _res = await http.post(
      Uri.parse(baseUrl + path),
      headers: _headers,
      body: jsonEncode(_body),
    );
    _parseResult();
  }

  void _parseResult() {
    try {
      //print("raw response: ${_res?.body}");
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
