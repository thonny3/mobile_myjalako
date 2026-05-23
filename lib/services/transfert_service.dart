import 'dart:convert';

import '../models/transfert.dart';
import 'api_client.dart';
import 'auth_service.dart';

class TransfertService {
  TransfertService._();

  static const String _basePath = '/api/transferts';

  static List<TransfertHistorique> _parseHistorique(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((e) => TransfertHistorique.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<List<TransfertHistorique>> getHistorique({int limit = 50}) async {
    final response = await ApiClient.get('$_basePath/historique?limit=$limit');
    if (response.statusCode != 200) {
      throw AuthException(
        ApiClient.extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
    return _parseHistorique(response.body);
  }

  static Future<void> transferCompteToCompte({
    required int idCompteSource,
    required int idCompteCible,
    required double montant,
  }) async {
    final response = await ApiClient.post('$_basePath/compte-vers-compte', {
      'id_compte_source': idCompteSource,
      'id_compte_cible': idCompteCible,
      'montant': montant,
    });

    if (response.statusCode != 200) {
      throw AuthException(
        ApiClient.extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
  }
}
