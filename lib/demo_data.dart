import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Données de démonstration en ariary malgache (MGA).
class DemoData {
  DemoData._();

  static const String currency = 'MGA';

  static const int totalBalance = 19125000;
  static const int revenues = 13950000;
  static const int expenses = 8325000;

  static const int foodSpent = 1440000;
  static const int foodLimit = 1800000;

  static const int transportSpent = 540000;
  static const int transportLimit = 900000;

  static String formatAmount(num amount) {
    final n = amount.round();
    final s = n.abs().toString();
    final buffer = StringBuffer();
    if (n < 0) buffer.write('- ');
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(s[i]);
    }
    return buffer.toString().trim();
  }

  static String formatSignedAmount(num amount) {
    final formatted = formatAmount(amount.abs());
    if (amount > 0) return '+ $formatted';
    if (amount < 0) return '- $formatted';
    return formatted;
  }

  static List<Map<String, dynamic>> get demoBudgets => [
    {
      'title': 'Alimentation',
      'spent': foodSpent,
      'limit': foodLimit,
      'icon': Icons.restaurant_rounded,
      'color': AppColors.accent,
      'bg': const Color(0xFFE8F5E9),
    },
    {
      'title': 'Transport',
      'spent': transportSpent,
      'limit': transportLimit,
      'icon': Icons.directions_car_rounded,
      'color': const Color(0xFF1976D2),
      'bg': const Color(0xFFE3F2FD),
    },
    {
      'title': 'Logement',
      'spent': 3825000,
      'limit': 4050000,
      'icon': Icons.home_rounded,
      'color': const Color(0xFF5D4037),
      'bg': const Color(0xFFEFEBE9),
    },
    {
      'title': 'Loisirs',
      'spent': 427500,
      'limit': 675000,
      'icon': Icons.sports_esports_rounded,
      'color': const Color(0xFF7B1FA2),
      'bg': const Color(0xFFF3E5F5),
    },
    {
      'title': 'Santé',
      'spent': 202500,
      'limit': 450000,
      'icon': Icons.medical_services_outlined,
      'color': const Color(0xFFC62828),
      'bg': const Color(0xFFFFEBEE),
    },
    {
      'title': 'Shopping',
      'spent': 945000,
      'limit': 810000,
      'icon': Icons.shopping_bag_outlined,
      'color': const Color(0xFFF57C00),
      'bg': const Color(0xFFFFECE0),
    },
    {
      'title': 'Éducation',
      'spent': 0,
      'limit': 540000,
      'icon': Icons.school_outlined,
      'color': const Color(0xFF00838F),
      'bg': const Color(0xFFE0F7FA),
    },
  ];

  static List<Map<String, dynamic>> get demoAccounts => [
    {
      'name': 'Compte courant',
      'bank': 'BFV-SG',
      'balance': 9675000.0,
      'icon': Icons.account_balance_rounded,
      'color': AppColors.accent,
      'bg': const Color(0xFFE8F5E9),
    },
    {
      'name': 'Épargne',
      'bank': 'BNI Madagascar',
      'balance': 8100000.0,
      'icon': Icons.savings_outlined,
      'color': const Color(0xFF2E7D32),
      'bg': const Color(0xFFE8F5E9),
    },
    {
      'name': 'Mvola',
      'bank': 'Mobile money',
      'balance': 1350000.0,
      'icon': Icons.phone_android_rounded,
      'color': const Color(0xFF1976D2),
      'bg': const Color(0xFFE3F2FD),
    },
    {
      'name': 'Espèces',
      'bank': 'Portefeuille',
      'balance': 900000.0,
      'icon': Icons.payments_outlined,
      'color': const Color(0xFFF57C00),
      'bg': const Color(0xFFFFECE0),
    },
  ];

  static List<Map<String, dynamic>> get demoTransactions => [
    {
      'title': 'Supermarché Jumbo',
      'subtitle': 'Aujourd\'hui, 14:30',
      'amount': -383400,
      'icon': Icons.shopping_bag_outlined,
      'bg': const Color(0xFFFFECE0),
      'fg': const Color(0xFFF57C00),
      'isExpense': true,
    },
    {
      'title': 'Café du centre',
      'subtitle': 'Aujourd\'hui, 09:15',
      'amount': -20250,
      'icon': Icons.local_cafe_outlined,
      'bg': const Color(0xFFFFFDE7),
      'fg': const Color(0xFFFBC02D),
      'isExpense': true,
    },
    {
      'title': 'Salaire mensuel',
      'subtitle': 'Hier',
      'amount': revenues,
      'icon': Icons.business_center_outlined,
      'bg': const Color(0xFFE8F5E9),
      'fg': const Color(0xFF2E7D32),
      'isExpense': false,
    },
    {
      'title': 'Abonnement streaming',
      'subtitle': '23 Mai',
      'amount': -72000,
      'icon': Icons.movie_outlined,
      'bg': const Color(0xFFE3F2FD),
      'fg': const Color(0xFF1976D2),
      'isExpense': true,
    },
    {
      'title': 'Station-service',
      'subtitle': '22 Mai',
      'amount': -292500,
      'icon': Icons.local_gas_station_outlined,
      'bg': const Color(0xFFF3E5F5),
      'fg': const Color(0xFF7B1FA2),
      'isExpense': true,
    },
  ];

  static List<Map<String, dynamic>> get demoGoals => [
    {
      'title': 'Vacances à Nosy Be',
      'deadline': 'Déc. 2026',
      'saved': 2100000,
      'target': 5000000,
      'icon': Icons.beach_access_rounded,
      'color': const Color(0xFF1976D2),
      'bg': const Color(0xFFE3F2FD),
    },
    {
      'title': 'Nouvelle moto',
      'deadline': 'Juin 2027',
      'saved': 3500000,
      'target': 8000000,
      'icon': Icons.two_wheeler_rounded,
      'color': const Color(0xFF5D4037),
      'bg': const Color(0xFFEFEBE9),
    },
    {
      'title': 'Fonds d\'urgence',
      'deadline': 'Atteint',
      'saved': 3000000,
      'target': 3000000,
      'icon': Icons.shield_outlined,
      'color': const Color(0xFF2E7D32),
      'bg': const Color(0xFFE8F5E9),
    },
    {
      'title': 'Rénovation maison',
      'deadline': 'Août 2027',
      'saved': 1200000,
      'target': 12000000,
      'icon': Icons.home_work_outlined,
      'color': AppColors.accent,
      'bg': const Color(0xFFE8F5E9),
    },
    {
      'title': 'Ordinateur portable',
      'deadline': 'Atteint',
      'saved': 2500000,
      'target': 2500000,
      'icon': Icons.laptop_mac_rounded,
      'color': const Color(0xFF7B1FA2),
      'bg': const Color(0xFFF3E5F5),
    },
    {
      'title': 'Mariage / Célébration',
      'deadline': 'Mars 2027',
      'saved': 4500000,
      'target': 15000000,
      'icon': Icons.celebration_outlined,
      'color': const Color(0xFFF57C00),
      'bg': const Color(0xFFFFECE0),
    },
  ];
}
