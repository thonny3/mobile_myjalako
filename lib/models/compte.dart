import 'package:flutter/material.dart';

import '../utils/compte_ui.dart';

class Compte {
  final int idCompte;
  final int? idUser;
  final String nom;
  final double solde;
  final String type;
  final String? devise;
  final String? accessRole;

  const Compte({
    required this.idCompte,
    this.idUser,
    required this.nom,
    required this.solde,
    required this.type,
    this.devise,
    this.accessRole,
  });

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseSolde(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  factory Compte.fromJson(Map<String, dynamic> json) {
    return Compte(
      idCompte: _parseId(json['id_compte']),
      idUser: json['id_user'] != null ? _parseId(json['id_user']) : null,
      nom: json['nom']?.toString().trim() ?? '',
      solde: _parseSolde(json['solde']),
      type: json['type']?.toString().trim() ?? '',
      devise: json['devise']?.toString(),
      accessRole: json['access_role']?.toString(),
    );
  }

  /// Format utilisé par l’UI existante (liste comptes).
  Map<String, dynamic> toUiMap() {
    final style = CompteUi.styleForType(type);
    return {
      'id_compte': idCompte,
      'name': nom,
      'type': type,
      'balance': solde,
      'icon': style.icon,
      'color': style.color,
      'bg': style.background,
      if (accessRole != null) 'access_role': accessRole,
    };
  }
}

/// Style visuel d’un type de compte (aperçu création).
class CompteTypeStyle {
  final String type;
  final String label;
  final IconData icon;
  final Color color;
  final Color background;
  final String defaultNom;

  const CompteTypeStyle({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
    required this.defaultNom,
  });
}
