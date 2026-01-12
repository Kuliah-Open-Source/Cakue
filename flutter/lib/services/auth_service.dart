import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../utils/error_handler.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.loginUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      ).timeout(Duration(seconds: AppConfig.requestTimeout));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Login successful'
        };
      } else {
        final error = ErrorHandler.handleHttpError(response);
        return {
          'success': false,
          'message': error.message
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': ErrorHandler.handleError(e)
      };
    }
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.registerUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      ).timeout(Duration(seconds: AppConfig.requestTimeout));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Registration successful'
        };
      } else {
        final error = ErrorHandler.handleHttpError(response);
        return {
          'success': false,
          'message': error.message
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': ErrorHandler.handleError(e)
      };
    }
  }
}