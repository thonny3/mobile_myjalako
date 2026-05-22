import 'dart:convert';

import '../models/dashboard_summary.dart';
import 'api_client.dart';
import 'auth_service.dart';

class DashboardService {
  DashboardService._();

  static Future<DashboardSummary> getSummary() async {
    final response = await ApiClient.get('/api/dashboard/summary');

    if (response.statusCode != 200) {
      throw AuthException(
        ApiClient.extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw const AuthException('Réponse tableau de bord invalide');
    }

    return DashboardSummary.fromJson(body);
  }
}
