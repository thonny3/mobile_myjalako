import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../models/compte.dart';

class CompteUi {
  CompteUi._();

  static const List<CompteTypeStyle> presets = [
    CompteTypeStyle(
      type: 'courant',
      label: 'Courant',
      defaultNom: 'Compte courant',
      icon: Icons.account_balance_rounded,
      color: AppColors.accent,
      background: Color(0xFFE8F5E9),
    ),
    CompteTypeStyle(
      type: 'epargne',
      label: 'Épargne',
      defaultNom: 'Épargne',
      icon: Icons.savings_outlined,
      color: Color(0xFF2E7D32),
      background: Color(0xFFE8F5E9),
    ),
    CompteTypeStyle(
      type: 'Mobile money',
      label: 'Mobile',
      defaultNom: 'Mvola',
      icon: Icons.phone_android_rounded,
      color: Color(0xFF1976D2),
      background: Color(0xFFE3F2FD),
    ),
    CompteTypeStyle(
      type: 'especes',
      label: 'Espèces',
      defaultNom: 'Espèces',
      icon: Icons.payments_outlined,
      color: Color(0xFFF57C00),
      background: Color(0xFFFFECE0),
    ),
    CompteTypeStyle(
      type: 'autre',
      label: 'Autre',
      defaultNom: '',
      icon: Icons.account_balance_wallet_outlined,
      color: Color(0xFF607D8B),
      background: Color(0xFFECEFF1),
    ),
  ];

  static CompteTypeStyle styleForType(String type) {
    final t = type.trim().toLowerCase();
    for (final preset in presets) {
      if (preset.type.toLowerCase() == t) return preset;
    }
    if (t.contains('mobile') || t.contains('mvola') || t.contains('orange')) {
      return presets[2];
    }
    if (t.contains('eparg')) return presets[1];
    if (t.contains('courant')) return presets[0];
    if (t.contains('espec') || t.contains('cash')) return presets[3];
    return presets.last;
  }

  static String formatTypeLabel(String type) {
    if (type.isEmpty) return 'Compte';
    final style = styleForType(type);
    if (style.type.toLowerCase() == type.trim().toLowerCase()) {
      return style.label;
    }
    return type;
  }

  static int presetIndexForType(String type) {
    final style = styleForType(type);
    final idx = presets.indexWhere((p) => p.type == style.type);
    return idx >= 0 ? idx : presets.length - 1;
  }
}
