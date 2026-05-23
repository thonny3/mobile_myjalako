import 'dart:convert';

import '../models/transaction_item.dart';
import 'api_client.dart';
import 'auth_service.dart';

class TransactionService {
  TransactionService._();

  static const String _basePath = '/api/transactions';

  static Future<List<TransactionItem>> getAll() async {
    final response = await ApiClient.get(_basePath);
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
        .map((e) => TransactionItem.fromJson(Map<String, dynamic>.from(e)))
        .where((t) => t.idTransaction > 0)
        .toList();
  }

  static List<Map<String, dynamic>> toUiList(List<TransactionItem> items) {
    return items.map((t) => t.toUiMap()).toList();
  }
}
