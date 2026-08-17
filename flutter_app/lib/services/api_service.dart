import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/template.dart';
import '../models/reference.dart';

class ApiService {
  static const String baseUrl = 'https://todo-next-five-mu.vercel.app/api';
  static const String _authTokenKey = 'todo_next_session_token';
  static const String _userEmailKey = 'todo_next_session_email';

  static String? _authToken;
  static String? _userEmail;

  static String? get userEmail => _userEmail;
  static bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_authTokenKey);
    _userEmail = prefs.getString(_userEmailKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = null;
    _userEmail = null;
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userEmailKey);
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
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['user'] != null && data['user']['email'] != null) {
          _userEmail = data['user']['email'] as String;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userEmailKey, _userEmail!);
        }
        return data;
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
            _userEmail = email;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_authTokenKey, token);
            await prefs.setString(_userEmailKey, email);
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
            _userEmail = email;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_authTokenKey, token);
            await prefs.setString(_userEmailKey, email);
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

  // --- REFERENCE API METHODS ---

  static Future<List<Reference>?> fetchReferences({String archived = 'all'}) async {
    try {
      final uri = Uri.parse('$baseUrl/references?archived=$archived');
      final res = await http.get(uri, headers: _getHeaders()).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final List decoded = jsonDecode(res.body);
        return decoded.map((item) => Reference.fromJson(Map<String, dynamic>.from(item))).toList();
      }
    } catch (_) {}
    return null;
  }

  static Future<Reference?> createReference(Reference reference) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/references'),
        headers: _getHeaders(),
        body: jsonEncode(reference.toJson()),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 201 || res.statusCode == 200) {
        return Reference.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> updateReference(String id, Map<String, dynamic> updates) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/references/$id'),
        headers: _getHeaders(),
        body: jsonEncode(updates),
      ).timeout(const Duration(seconds: 8));

      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<bool> deleteReference(String id) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/references/$id'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 8));

      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<bool> archiveReference(String id) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/references/$id/archive'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 8));

      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<bool> restoreReference(String id) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/references/$id/restore'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 8));

      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }
}

