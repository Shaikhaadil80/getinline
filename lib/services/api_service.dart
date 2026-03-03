// =============================================================================
// GETINLINE FLUTTER - services/api_service.dart
// Complete HTTP Client with Error Handling, Interceptors, and Token Management
// =============================================================================

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';
import 'database_service.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final DatabaseService _dbService = DatabaseService();
  
  // Base headers
  Map<String, String> get _baseHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final headers = Map<String, String>.from(_baseHeaders);
    final token = await _dbService.getUserToken();
    // print(  '🔑 Token: $token');
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      headers['Content-Type'] =  'application/json';
    }
    return headers;
  }

  // =============================================================================
  // HTTP METHODS
  // =============================================================================

  /// GET Request
  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      var uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      
      // Add query parameters if provided
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await _getHeaders();
      
      print('🌐 GET Request: $uri');
      
      final response = await http.get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(ValidationMessages.networkError);
    } on TimeoutException {
      throw ApiException(ValidationMessages.timeoutError);
    } catch (e) {
      print('❌ GET Error: $e');
      throw ApiException(e.toString());
    }
  }

  /// POST Request
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders();
      
      log('🌐 POST Request: $uri');
      log('📦 HEADER: ${jsonEncode(headers)}');
      log('📦 Body: ${jsonEncode(body)}');
      
      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(ValidationMessages.networkError);
    } on TimeoutException {
      throw ApiException(ValidationMessages.timeoutError);
    } catch (e) {
      print('❌ POST Error: $e');
      throw ApiException(e.toString());
    }
  }

  /// PUT Request
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders();
      
      print('🌐 PUT Request: $uri');
      print('📦 Body: ${jsonEncode(body)}');
      
      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(ValidationMessages.networkError);
    } on TimeoutException {
      throw ApiException(ValidationMessages.timeoutError);
    } catch (e) {
      print('❌ PUT Error: $e');
      throw ApiException(e.toString());
    }
  }

  /// PATCH Request
  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders();
      
      print('🌐 PATCH Request: $uri');
      print('📦 Body: ${jsonEncode(body)}');
      
      final response = await http.patch(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(ValidationMessages.networkError);
    } on TimeoutException {
      throw ApiException(ValidationMessages.timeoutError);
    } catch (e) {
      print('❌ PATCH Error: $e');
      throw ApiException(e.toString());
    }
  }

  /// DELETE Request
  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders();
      
      print('🌐 DELETE Request: $uri');
      
      final response = await http.delete(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(ValidationMessages.networkError);
    } on TimeoutException {
      throw ApiException(ValidationMessages.timeoutError);
    } catch (e) {
      print('❌ DELETE Error: $e');
      throw ApiException(e.toString());
    }
  }

  // =============================================================================
  // RESPONSE HANDLER
  // =============================================================================

  dynamic _handleResponse(http.Response response) {
    print('📥 Response Status: ${response.statusCode}');
    print('📥 Response Body: ${response.body}');

    switch (response.statusCode) {
      case 200:
      case 201:
        // Success
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
        
      case 204:
        // No content (success)
        return null;
        
      case 400:
        // Bad request
        final error = _parseError(response);
        throw ApiException(error ?? 'Bad request');
        
      case 401:
        // Unauthorized
        throw UnauthorizedException(ErrorMessages.sessionExpired);
        
      case 403:
        // Forbidden
        throw ForbiddenException(ErrorMessages.forbidden);
        
      case 404:
        // Not found
        throw NotFoundException(ErrorMessages.dataNotFound);
        
      case 422:
        // Validation error
        final error = _parseError(response);
        throw ValidationException(error ?? 'Validation failed');
        
      case 500:
      case 502:
      case 503:
        // Server error
        throw ServerException(ErrorMessages.forbidden);
        
      default:
        throw ApiException('Unexpected error: ${response.statusCode}');
    }
  }

  // =============================================================================
  // ERROR PARSER
  // =============================================================================

  String? _parseError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      
      // Try different error message fields
      if (data is Map<String, dynamic>) {
        return data['message'] ?? 
               data['error'] ?? 
               data['msg'] ?? 
               data['detail'];
      }
      
      return data.toString();
    } catch (e) {
      return response.body;
    }
  }

  // =============================================================================
  // MULTIPART REQUEST (For File Uploads)
  // =============================================================================

Future<dynamic> uploadFile(
  String endpoint,
  XFile file,
  String fieldName, {
  Map<String, String>? additionalFields,
}) async {
  try {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _getHeaders();
    headers.remove('Content-Type');

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);

    if (kIsWeb) {
      // ✅ WEB: use bytes
      final bytes = await file.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: file.name,
        ),
      );
    } else {
      // ✅ MOBILE: use file path
      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
        ),
      );
    }

    if (additionalFields != null) {
      request.fields.addAll(additionalFields);
    }

    final streamedResponse = await request.send()
          .timeout(const Duration(seconds: 60));
    final response =
        await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  } catch (e) {
    throw ApiException(e.toString());
  }
}

  // Future<dynamic> uploadFile(
  //   String endpoint,
  //   String filePath,
  //   String fieldName, {
  //   Map<String, String>? additionalFields,
  // }) async {
  //   try {
  //     final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
  //     final headers = await _getHeaders();
  //     headers.remove('Content-Type'); // Let http package set it
      
  //     print('🌐 MULTIPART Request: $uri');
      
  //     final request = http.MultipartRequest('POST', uri);
  //     request.headers.addAll(headers);
      
  //     // Add file
  //     final file = await http.MultipartFile.fromPath(fieldName, filePath);
  //     request.files.add(file);
      
  //     // Add additional fields
  //     if (additionalFields != null) {
  //       request.fields.addAll(additionalFields);
  //     }
      
  //     final streamedResponse = await request.send()
  //         .timeout(const Duration(seconds: 60));
  //     final response = await http.Response.fromStream(streamedResponse);
      
  //     return _handleResponse(response);
  //   } on SocketException {
  //     throw ApiException(ValidationMessages.networkError);
  //   } on TimeoutException {
  //     throw ApiException(ValidationMessages.timeoutError);
  //   } catch (e) {
  //     print('❌ Upload Error: $e');
  //     throw ApiException(e.toString());
  //   }
  // }

  // =============================================================================
  // TOKEN MANAGEMENT
  // =============================================================================

  Future<void> setAuthToken(String token) async {
    await _dbService.saveUserToken(token);
  }

  Future<void> clearAuthToken() async {
    await _dbService.clearUserToken();
  }
}

// =============================================================================
// CUSTOM EXCEPTIONS
// =============================================================================

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

class TimeoutException extends ApiException {
  TimeoutException(String message) : super(message);
}
