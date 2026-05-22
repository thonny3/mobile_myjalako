import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'auth_service.dart';
import 'auth_storage.dart';

class ApiClient {
  ApiClient._();

  static const Duration timeout = Duration(seconds: 90);

  static Future<Map<String, String>> authHeaders() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      throw const AuthException('Session expirée. Reconnectez-vous.');
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static String extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final msg = body['message'] ?? body['error'];
        if (msg is String && msg.isNotEmpty) return msg;
        if (msg is Map && msg['message'] is String) return msg['message'] as String;
      }
    } catch (_) {}
    return 'Erreur serveur (${response.statusCode})';
  }

  static String networkErrorMessage(Object error) {
    if (error is TimeoutException) {
      return 'Le serveur met trop de temps à répondre. Réessayez.';
    }
    if (error is SocketException) {
      return 'Pas de connexion réseau.';
    }
    if (error is AuthException) return error.message;
    return 'Erreur : $error';
  }

  static Future<http.Response> get(String path) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    try {
      return await http
          .get(uri, headers: await authHeaders())
          .timeout(timeout);
    } catch (e) {
      throw AuthException(networkErrorMessage(e));
    }
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    try {
      return await http
          .post(uri, headers: await authHeaders(), body: jsonEncode(body))
          .timeout(timeout);
    } catch (e) {
      throw AuthException(networkErrorMessage(e));
    }
  }

  static Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    try {
      return await http
          .put(uri, headers: await authHeaders(), body: jsonEncode(body))
          .timeout(timeout);
    } catch (e) {
      throw AuthException(networkErrorMessage(e));
    }
  }

  static Future<http.Response> delete(String path) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    try {
      return await http
          .delete(uri, headers: await authHeaders())
          .timeout(timeout);
    } catch (e) {
      throw AuthException(networkErrorMessage(e));
    }
  }
}
