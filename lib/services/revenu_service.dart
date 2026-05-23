import 'dart:convert';

import '../models/revenu.dart';
import 'api_client.dart';
import 'auth_service.dart';

class RevenuService {
  RevenuService._();

  static const String _basePath = '/api/revenus';
  static const String _categoriesPath = '/api/categories/revenues';

  static List<Revenu> _parseList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((e) => Revenu.fromJson(Map<String, dynamic>.from(e)))
        .where((r) => r.idRevenu > 0)
        .toList();
  }

  static Future<List<Revenu>> getAll({int? idCompte}) async {
    final uri = idCompte != null ? '$_basePath?id_compte=$idCompte' : _basePath;
    final response = await ApiClient.get(uri);
    if (response.statusCode != 200) {
      throw AuthException(
        ApiClient.extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
    return _parseList(response.body);
  }

  static Future<List<CategorieRevenu>> getCategories() async {
    final response = await ApiClient.get(_categoriesPath);
    if (response.statusCode != 200) {
      throw AuthException(
        ApiClient.extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((e) => CategorieRevenu.fromJson(Map<String, dynamic>.from(e)))
        .where((c) => c.id > 0)
        .toList();
  }

  static Future<int> create({
    required double montant,
    required String source,
    required String dateRevenu,
    required int idCategorieRevenu,
    required int idCompte,
  }) async {
    final response = await ApiClient.post(_basePath, {
      'montant': montant,
      'source': source.trim(),
      'date_revenu': dateRevenu,
      'id_categorie_revenu': idCategorieRevenu,
      'id_compte': idCompte,
    });

    if (response.statusCode != 200) {
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

  static Revenu? _parseOne(String body) {
    final decoded = jsonDecode(body);
    if (decoded is List && decoded.isNotEmpty) {
      final first = decoded.first;
      if (first is Map) {
        return Revenu.fromJson(Map<String, dynamic>.from(first));
      }
    }
    if (decoded is Map<String, dynamic>) {
      return Revenu.fromJson(decoded);
    }
    return null;
  }

  static Future<Revenu> getById(int idRevenu) async {
    final response = await ApiClient.get('$_basePath/$idRevenu');
    if (response.statusCode != 200) {
      throw AuthException(
        ApiClient.extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
    final revenu = _parseOne(response.body);
    if (revenu == null || revenu.idRevenu <= 0) {
      throw const AuthException('Revenu introuvable');
    }
    return revenu;
  }

  static Future<void> update({
    required int idRevenu,
    required double montant,
    required String source,
    required String dateRevenu,
    required int idCategorieRevenu,
    required int idCompte,
  }) async {
    final response = await ApiClient.put('$_basePath/$idRevenu', {
      'montant': montant,
      'source': source.trim(),
      'date_revenu': dateRevenu,
      'id_categorie_revenu': idCategorieRevenu,
      'id_compte': idCompte,
    });

    if (response.statusCode != 200) {
      throw AuthException(
        ApiClient.extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
  }

  static Future<void> delete(int idRevenu) async {
    final response = await ApiClient.delete('$_basePath/$idRevenu');
    if (response.statusCode != 200) {
      throw AuthException(
        ApiClient.extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
  }
}
