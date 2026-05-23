import 'dart:convert';

import '../models/depense.dart';
import 'api_client.dart';
import 'auth_service.dart';

class DepenseService {
  DepenseService._();

  static const String _basePath = '/api/depenses';
  static const String _categoriesPath = '/api/categories/depenses';

  static List<Depense> _parseList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((e) => Depense.fromJson(Map<String, dynamic>.from(e)))
        .where((d) => d.idDepense > 0)
        .toList();
  }

  static Future<List<Depense>> getAll({int? idCompte}) async {
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

  static Future<Depense> getById(int idDepense) async {
    final all = await getAll();
    for (final d in all) {
      if (d.idDepense == idDepense) return d;
    }
    throw const AuthException('Dépense introuvable');
  }

  static Future<List<CategorieDepense>> getCategories() async {
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
        .map((e) => CategorieDepense.fromJson(Map<String, dynamic>.from(e)))
        .where((c) => c.id > 0)
        .toList();
  }

  static Future<void> create({
    required double montant,
    required String description,
    required String dateDepense,
    required int idCategorieDepense,
    required int idCompte,
  }) async {
    final response = await ApiClient.post(_basePath, {
      'montant': montant,
      'description': description.trim(),
      'date_depense': dateDepense,
      'id_categorie_depense': idCategorieDepense,
      'id_compte': idCompte,
    });

    if (response.statusCode != 200) {
      throw AuthException(
        ApiClient.extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
  }

  static Future<void> update({
    required int idDepense,
    required double montant,
    required String description,
    required String dateDepense,
    required int idCategorieDepense,
    required int idCompte,
  }) async {
    final response = await ApiClient.put('$_basePath/$idDepense', {
      'montant': montant,
      'description': description.trim(),
      'date_depense': dateDepense,
      'id_categorie_depense': idCategorieDepense,
      'id_compte': idCompte,
    });

    if (response.statusCode != 200) {
      throw AuthException(
        ApiClient.extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
  }

  static Future<void> delete(int idDepense) async {
    final response = await ApiClient.delete('$_basePath/$idDepense');
    if (response.statusCode != 200) {
      throw AuthException(
        ApiClient.extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
  }
}
