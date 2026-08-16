import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/template.dart';

class ApiService {
  static const String baseUrl = 'https://todo-next-five-mu.vercel.app/api';
  static const String _authTokenKey = 'todo_next_session_token';

  static String? _authToken;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_authTokenKey);
  }

  static Map<String, String> _getHeaders() {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
      headers['x-app-session'] = _authToken!;
    }
    return headers;
  }

  static Future<Map<String, dynamic>> checkAuthStatus() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/auth'), headers: _getHeaders()).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {'authRequired': false, 'authenticated': true};
  }

  static Future<bool> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final token = body['token'] as String?;
          if (token != null && token.isNotEmpty) {
            _authToken = token;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_authTokenKey, token);
          }
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  static Future<bool> signup(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final token = body['token'] as String?;
          if (token != null && token.isNotEmpty) {
            _authToken = token;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_authTokenKey, token);
          }
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  static Future<List<Task>?> fetchTasks() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/tasks'), headers: _getHeaders()).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final List decoded = jsonDecode(res.body);
        return decoded.map((item) => Task.fromJson(Map<String, dynamic>.from(item))).toList();
      }
    } catch (_) {}
    return null;
  }

  static Future<Task?> createTask(Task task) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: _getHeaders(),
        body: jsonEncode(task.toJson()),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 201 || res.statusCode == 200) {
        return Task.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> updateTask(String id, Map<String, dynamic> updates) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/tasks/$id'),
        headers: _getHeaders(),
        body: jsonEncode(updates),
      ).timeout(const Duration(seconds: 8));

      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<bool> deleteTask(String id) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/tasks/$id'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 8));

      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<bool> completeTask(String id, String completionDate) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/tasks/$id/complete'),
        headers: _getHeaders(),
        body: jsonEncode({'completionDate': completionDate}),
      ).timeout(const Duration(seconds: 8));

      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<bool> skipTask(String id) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/tasks/$id/skip'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 8));

      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<List<Template>?> fetchTemplates() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/templates'), headers: _getHeaders()).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final List decoded = jsonDecode(res.body);
        return decoded.map((item) => Template.fromJson(Map<String, dynamic>.from(item))).toList();
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> createTemplate(Template template) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/templates'),
        headers: _getHeaders(),
        body: jsonEncode(template.toJson()),
      ).timeout(const Duration(seconds: 8));

      return res.statusCode == 201 || res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<bool> updateTemplate(String id, Map<String, dynamic> updates) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/templates/$id'),
        headers: _getHeaders(),
        body: jsonEncode(updates),
      ).timeout(const Duration(seconds: 8));

      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<bool> deleteTemplate(String id) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/templates/$id'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 8));

      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }
}
