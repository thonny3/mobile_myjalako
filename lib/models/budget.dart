import 'package:flutter/material.dart';

import '../app_colors.dart';

class Budget {
  final int idBudget;
  final int idCategorieDepense;
  final String categorie;
  final DateTime? mois;
  final double montantMax;
  final double montantRestant;
  final double montantDepense;
  final double pourcentageUtilise;

  const Budget({
    required this.idBudget,
    required this.idCategorieDepense,
    required this.categorie,
    this.mois,
    required this.montantMax,
    required this.montantRestant,
    required this.montantDepense,
    required this.pourcentageUtilise,
  });

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseNum(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _parseMois(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return DateTime(value.year, value.month);
    final s = value.toString().trim();
    if (s.isEmpty) return null;
    if (s.length >= 7) {
      final y = int.tryParse(s.substring(0, 4));
      final m = int.tryParse(s.substring(5, 7));
      if (y != null && m != null) return DateTime(y, m);
    }
    final d = DateTime.tryParse(s.length <= 10 ? s : s.substring(0, 10));
    return d != null ? DateTime(d.year, d.month) : null;
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      idBudget: _parseId(json['id_budget']),
      idCategorieDepense: _parseId(json['id_categorie_depense']),
      categorie: json['categorie']?.toString().trim() ?? 'Budget',
      mois: _parseMois(json['mois']),
      montantMax: _parseNum(json['montant_max']),
      montantRestant: _parseNum(json['montant_restant']),
      montantDepense: _parseNum(json['montant_depense']),
      pourcentageUtilise: _parseNum(json['pourcentage_utilise']),
    );
  }

  bool isForMonth(DateTime month) {
    final m = mois;
    if (m == null) return false;
    return m.year == month.year && m.month == month.month;
  }

  double get spent => montantDepense;

  double get limit => montantMax;

  double get remaining => montantMax - montantDepense;

  bool get isOver => montantDepense > montantMax;

  double get progress =>
      montantMax > 0 ? (montantDepense / montantMax).clamp(0.0, 1.2) : 0.0;

  static Map<String, dynamic> styleForCategory(String name) {
    final key = name.toLowerCase().trim();
    if (key.contains('aliment') || key.contains('restau')) {
      return _style(
        Icons.restaurant_rounded,
        AppColors.accent,
        const Color(0xFFE8F5E9),
      );
    }
    if (key.contains('transport') || key.contains('voiture')) {
      return _style(
        Icons.directions_car_rounded,
        const Color(0xFF1976D2),
        const Color(0xFFE3F2FD),
      );
    }
    if (key.contains('logement') || key.contains('loyer')) {
      return _style(
        Icons.home_rounded,
        const Color(0xFF5D4037),
        const Color(0xFFEFEBE9),
      );
    }
    if (key.contains('loisir')) {
      return _style(
        Icons.sports_esports_rounded,
        const Color(0xFF7B1FA2),
        const Color(0xFFF3E5F5),
      );
    }
    if (key.contains('sant')) {
      return _style(
        Icons.medical_services_outlined,
        const Color(0xFFC62828),
        const Color(0xFFFFEBEE),
      );
    }
    if (key.contains('shop')) {
      return _style(
        Icons.shopping_bag_outlined,
        const Color(0xFFF57C00),
        const Color(0xFFFFECE0),
      );
    }
    if (key.contains('educ') || key.contains('ecole')) {
      return _style(
        Icons.school_outlined,
        const Color(0xFF00838F),
        const Color(0xFFE0F7FA),
      );
    }
    return _style(
      Icons.category_outlined,
      const Color(0xFF607D8B),
      const Color(0xFFECEFF1),
    );
  }

  static Map<String, dynamic> _style(IconData icon, Color color, Color bg) {
    return {'icon': icon, 'color': color, 'bg': bg};
  }

  Map<String, dynamic> toUiMap() {
    final s = styleForCategory(categorie);
    return {
      'title': categorie,
      'spent': spent.round(),
      'limit': limit.round(),
      'icon': s['icon'] as IconData,
      'color': s['color'] as Color,
      'bg': s['bg'] as Color,
      'id_budget': idBudget,
    };
  }
}
