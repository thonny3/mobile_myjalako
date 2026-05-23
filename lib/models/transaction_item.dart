import 'package:flutter/material.dart';

class TransactionItem {
  final int idTransaction;
  final int? idUser;
  final double montant;
  final DateTime? dateTransaction;
  final String description;
  final String type;
  final int? idCategorie;
  final int? idCompte;
  final String? categorieNom;
  final String? compteNom;
  final String? objectifNom;

  const TransactionItem({
    required this.idTransaction,
    this.idUser,
    required this.montant,
    this.dateTransaction,
    required this.description,
    required this.type,
    this.idCategorie,
    this.idCompte,
    this.categorieNom,
    this.compteNom,
    this.objectifNom,
  });

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseMontant(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final s = value.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s.length <= 10 ? s : s.substring(0, 10));
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      idTransaction: _parseId(json['id_transaction']),
      idUser: json['id_user'] != null ? _parseId(json['id_user']) : null,
      montant: _parseMontant(json['montant']),
      dateTransaction: _parseDate(json['date_transaction']),
      description: json['description']?.toString().trim() ?? '',
      type: json['type']?.toString().trim() ?? '',
      idCategorie: json['id_categorie'] != null ? _parseId(json['id_categorie']) : null,
      idCompte: json['id_compte'] != null ? _parseId(json['id_compte']) : null,
      categorieNom: json['categorie_nom']?.toString(),
      compteNom: json['compte_nom']?.toString(),
      objectifNom: json['objectif_nom']?.toString(),
    );
  }

  bool get isCurrentMonth {
    final d = dateTransaction;
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month;
  }

  bool get isRevenu => type == 'revenu';
  bool get isDepense => type == 'depense' || type == 'abonnement';

  int get amountForUi {
    switch (type) {
      case 'revenu':
        return montant.round();
      case 'depense':
      case 'abonnement':
        return -montant.abs().round();
      default:
        return montant.round();
    }
  }

  bool get isExpense => amountForUi < 0;

  String get typeLabel {
    switch (type) {
      case 'revenu':
        return 'Revenu';
      case 'depense':
        return 'Dépense';
      case 'abonnement':
        return 'Abonnement';
      case 'contribution':
        return 'Contribution';
      case 'remboursement_dette':
        return 'Remboursement';
      default:
        return type.isNotEmpty ? type : 'Transaction';
    }
  }

  String get subtitle {
    final parts = <String>[];
    if (dateTransaction != null) {
      final d = dateTransaction!;
      parts.add(
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}',
      );
    }
    parts.add(typeLabel);
    if (categorieNom != null && categorieNom!.isNotEmpty) {
      parts.add(categorieNom!);
    }
    if (compteNom != null && compteNom!.isNotEmpty) {
      parts.add(compteNom!);
    }
    return parts.join(' · ');
  }

  IconData get icon {
    switch (type) {
      case 'revenu':
        return Icons.trending_up_rounded;
      case 'depense':
        return Icons.shopping_bag_outlined;
      case 'abonnement':
        return Icons.subscriptions_outlined;
      case 'contribution':
        return Icons.savings_outlined;
      case 'remboursement_dette':
        return Icons.payment_rounded;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  Color get foregroundColor {
    if (isExpense) {
      return type == 'remboursement_dette'
          ? const Color(0xFF5D4037)
          : const Color(0xFFD32F2F);
    }
    return const Color(0xFF2E7D32);
  }

  Color get backgroundColor {
    if (isExpense) {
      switch (type) {
        case 'abonnement':
          return const Color(0xFFE3F2FD);
        case 'remboursement_dette':
          return const Color(0xFFEFEBE9);
        default:
          return const Color(0xFFFFEBEE);
      }
    }
    return const Color(0xFFE8F5E9);
  }

  Map<String, dynamic> toUiMap() {
    return {
      'id_transaction': idTransaction,
      'type': type,
      'title': description.isNotEmpty ? description : typeLabel,
      'subtitle': subtitle,
      'amount': amountForUi,
      'icon': icon,
      'bg': backgroundColor,
      'fg': foregroundColor,
      'isExpense': isExpense,
    };
  }
}
