import 'dart:convert';

import '../models/budget.dart';
import 'api_client.dart';
import 'auth_service.dart';

class BudgetService {
  BudgetService._();

  static const String _basePath = '/api/budgets';

  static List<Budget> _parseList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((e) => Budget.fromJson(Map<String, dynamic>.from(e)))
        .where((b) => b.idBudget > 0)
        .toList();
  }

  static Future<List<Budget>> getAll() async {
    final response = await ApiClient.get(_basePath);
    if (response.statusCode != 200) {
      throw AuthException(
        ApiClient.extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
    return _parseList(response.body);
  }

  static Future<Budget> getById(int idBudget) async {
    final all = await getAll();
    for (final b in all) {
      if (b.idBudget == idBudget) return b;
    }
    throw const AuthException('Budget introuvable');
  }

  static Future<int> create({
    required int idCategorieDepense,
    required String mois,
    required double montantMax,
  }) async {
    final response = await ApiClient.post(_basePath, {
      'id_categorie_depense': idCategorieDepense,
      'mois': mois,
      'montant_max': montantMax,
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

  static Future<void> update({
    required int idBudget,
    required double montantMax,
    required double montantRestant,
  }) async {
    final response = await ApiClient.put('$_basePath/$idBudget', {
      'montant_max': montantMax,
      'montant_restant': montantRestant,
    });

    if (response.statusCode != 200) {
      throw AuthException(
        ApiClient.extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
  }

  static Future<void> delete(int idBudget) async {
    final response = await ApiClient.delete('$_basePath/$idBudget');
    if (response.statusCode != 200) {
      throw AuthException(
        ApiClient.extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
  }

  static String formatMoisApi(DateTime month) {
    return '${month.year}-${month.month.toString().padLeft(2, '0')}-01';
  }
}
