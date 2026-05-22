import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/auth_user.dart';
import 'auth_storage.dart';

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthSession {
  final String token;
  final AuthUser user;

  const AuthSession({required this.token, required this.user});
}

class AuthService {
  AuthService._();

  /// Render peut mettre ~30–90 s à se réveiller (cold start).
  static const Duration _requestTimeout = Duration(seconds: 90);

  static Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static String _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final msg = body['message'] ?? body['error'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
    } catch (_) {}
    return 'Erreur serveur (${response.statusCode})';
  }

  static AuthSession _parseLoginResponse(String responseBody) {
    final dynamic decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      throw const AuthException('Réponse serveur invalide');
    }

    final token = decoded['token']?.toString();
    final userRaw = decoded['user'];
    if (token == null || token.isEmpty) {
      throw const AuthException('Token manquant dans la réponse serveur');
    }
    if (userRaw is! Map) {
      throw const AuthException('Profil utilisateur manquant dans la réponse');
    }

    return AuthSession(
      token: token,
      user: AuthUser.fromJson(Map<String, dynamic>.from(userRaw)),
    );
  }

  static Future<void> _persistSession(AuthSession session) async {
    try {
      await AuthStorage.saveSession(token: session.token, user: session.user);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthStorage.saveSession ignoré: $e');
      }
    }
  }

  static String _networkErrorMessage(Object error) {
    if (error is TimeoutException) {
      return 'Le serveur met trop de temps à répondre. '
          'Sur Render, attendez 1 minute puis réessayez.';
    }
    if (error is SocketException) {
      return 'Pas de connexion réseau. Vérifiez votre internet.';
    }
    if (error is HandshakeException || error is TlsException) {
      return 'Erreur de sécurité SSL avec le serveur.';
    }
    if (error is http.ClientException) {
      return 'Connexion interrompue : ${error.message}';
    }
    if (error is FormatException) {
      return 'Réponse serveur illisible.';
    }
    return 'Erreur technique : $error';
  }

  static Future<http.Response> _postJson(Uri uri, Map<String, dynamic> body) async {
    try {
      return await http
          .post(uri, headers: _jsonHeaders, body: jsonEncode(body))
          .timeout(_requestTimeout);
    } on TimeoutException {
      rethrow;
    } on SocketException {
      rethrow;
    } catch (e) {
      throw AuthException(_networkErrorMessage(e));
    }
  }

  static Future<void> ping() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/ping');
    try {
      final response = await http.get(uri).timeout(_requestTimeout);
      if (response.statusCode != 200) {
        throw AuthException(
          'Impossible de joindre le serveur (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(_networkErrorMessage(e));
    }
  }

  static Future<AuthSession> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String currency,
  }) async {
    final uri = Uri.parse('${ApiConfig.authBaseUrl}/register');
    final response = await _postJson(uri, {
      'nom': nom.trim(),
      'prenom': prenom.trim(),
      'email': email.trim(),
      'password': password,
      'currency': currency,
    });

    if (response.statusCode != 201) {
      throw AuthException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    return login(email: email, password: password);
  }

  static Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.authBaseUrl}/login');
    final response = await _postJson(uri, {
      'email': email.trim(),
      'password': password,
    });

    if (response.statusCode != 200) {
      throw AuthException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    final session = _parseLoginResponse(response.body);
    await _persistSession(session);
    return session;
  }

  static Future<AuthUser> verifyToken(String token) async {
    final uri = Uri.parse('${ApiConfig.authBaseUrl}/verify');
    http.Response response;
    try {
      response = await http
          .get(
            uri,
            headers: {
              ..._jsonHeaders,
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_requestTimeout);
    } catch (e) {
      throw AuthException(_networkErrorMessage(e));
    }

    if (response.statusCode != 200) {
      throw AuthException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw const AuthException('Réponse serveur invalide');
    }
    final userRaw = body['user'];
    if (userRaw is! Map) {
      throw const AuthException('Profil utilisateur manquant');
    }

    final user = AuthUser.fromJson(Map<String, dynamic>.from(userRaw));
    await _persistSession(AuthSession(token: token, user: user));
    return user;
  }

  static Future<void> forgotPassword({required String email}) async {
    final uri = Uri.parse('${ApiConfig.authBaseUrl}/forgot-password');
    final response = await _postJson(uri, {'email': email.trim()});

    if (response.statusCode != 200) {
      throw AuthException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
  }

  static Future<void> logout() => AuthStorage.clear();
}
