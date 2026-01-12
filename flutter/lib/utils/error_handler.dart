import 'dart:io';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, [this.statusCode]);
  
  @override
  String toString() => message;
}

class ErrorHandler {
  static String handleError(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (error is HttpException) {
      return 'Server error. Please try again later.';
    } else if (error is FormatException) {
      return 'Invalid data format received.';
    } else if (error is ApiException) {
      return error.message;
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
  
  static ApiException handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return ApiException('Invalid request. Please check your input.');
      case 401:
        return ApiException('Authentication failed. Please login again.');
      case 403:
        return ApiException('Access denied.');
      case 404:
        return ApiException('Resource not found.');
      case 429:
        return ApiException('Too many requests. Please try again later.');
      case 500:
        return ApiException('Server error. Please try again later.');
      default:
        return ApiException('Network error (${response.statusCode})');
    }
  }
}