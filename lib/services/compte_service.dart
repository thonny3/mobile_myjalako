import 'dart:convert';

import 'api_client.dart';
import 'auth_service.dart';

import '../models/compte.dart';

class CompteService {
  CompteService._();

  static const String _basePath = '/api/comptes';

  static List<Compte> _parseList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((e) => Compte.fromJson(Map<String, dynamic>.from(e)))
        .where((c) => c.idCompte > 0)
        .toList();
  }

  static Future<List<Compte>> getMyAccounts() async {
    final response = await ApiClient.get('$_basePath/mycompte/user');
    if (response.statusCode != 200) {
      throw AuthException(
        ApiClient.extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
    return _parseList(response.body);
  }

  static Future<Compte> getById(int idCompte) async {
    final response = await ApiClient.get('$_basePath/$idCompte');
    if (response.statusCode != 200) {
      throw AuthException(
        ApiClient.extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw const AuthException('Compte introuvable');
    }
    return Compte.fromJson(body);
  }

  static Future<int> create({
    required String nom,
    required double solde,
    required String type,
  }) async {
    final response = await ApiClient.post(_basePath, {
      'nom': nom.trim(),
      'solde': solde,
      'type': type.trim(),
    });

    if (response.statusCode != 201) {
      throw AuthException(
        ApiClient.extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      final id = body['id'];
      if (id is int) return id;
      if (id is num) return id.toInt();
      if (id is String) return int.tryParse(id) ?? 0;
    }
    return 0;
  }

  static Future<void> update({
    required int idCompte,
    required String nom,
    required double solde,
    required String type,
  }) async {
    final response = await ApiClient.put('$_basePath/$idCompte', {
      'nom': nom.trim(),
      'solde': solde,
      'type': type.trim(),
    });

    if (response.statusCode != 200) {
      throw AuthException(
        ApiClient.extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
  }

  static Future<void> delete(int idCompte) async {
    final response = await ApiClient.delete('$_basePath/$idCompte');
    if (response.statusCode != 200) {
      throw AuthException(
        ApiClient.extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
  }
}
