import 'package:flutter/material.dart';

class Revenu {
  final int idRevenu;
  final int? idUser;
  final double montant;
  final DateTime? dateRevenu;
  final String source;
  final int? idCategorieRevenu;
  final int? idCompte;
  final String? categorieNom;
  final String? compteNom;

  const Revenu({
    required this.idRevenu,
    this.idUser,
    required this.montant,
    this.dateRevenu,
    required this.source,
    this.idCategorieRevenu,
    this.idCompte,
    this.categorieNom,
    this.compteNom,
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

  Revenu copyWith({
    double? montant,
    DateTime? dateRevenu,
    String? source,
    int? idCategorieRevenu,
    int? idCompte,
    String? categorieNom,
    String? compteNom,
  }) {
    return Revenu(
      idRevenu: idRevenu,
      idUser: idUser,
      montant: montant ?? this.montant,
      dateRevenu: dateRevenu ?? this.dateRevenu,
      source: source ?? this.source,
      idCategorieRevenu: idCategorieRevenu ?? this.idCategorieRevenu,
      idCompte: idCompte ?? this.idCompte,
      categorieNom: categorieNom ?? this.categorieNom,
      compteNom: compteNom ?? this.compteNom,
    );
  }

  factory Revenu.fromJson(Map<String, dynamic> json) {
    return Revenu(
      idRevenu: _parseId(json['id_revenu']),
      idUser: json['id_user'] != null ? _parseId(json['id_user']) : null,
      montant: _parseMontant(json['montant']),
      dateRevenu: _parseDate(json['date_revenu']),
      source: json['source']?.toString().trim() ?? '',
      idCategorieRevenu: json['id_categorie_revenu'] != null
          ? _parseId(json['id_categorie_revenu'])
          : null,
      idCompte: json['id_compte'] != null ? _parseId(json['id_compte']) : null,
      categorieNom: json['categorie_nom']?.toString(),
      compteNom: json['compte_nom']?.toString(),
    );
  }

  bool get isCurrentMonth {
    final d = dateRevenu;
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month;
  }

  String get subtitle {
    final parts = <String>[];
    if (dateRevenu != null) {
      final d = dateRevenu!;
      parts.add(
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}',
      );
    }
    if (categorieNom != null && categorieNom!.isNotEmpty) {
      parts.add(categorieNom!);
    }
    if (compteNom != null && compteNom!.isNotEmpty) {
      parts.add(compteNom!);
    }
    return parts.isEmpty ? 'Revenu' : parts.join(' · ');
  }

  Map<String, dynamic> toUiMap() {
    return {
      'id_revenu': idRevenu,
      'title': source.isNotEmpty ? source : 'Revenu',
      'subtitle': subtitle,
      'amount': montant.round(),
      'icon': Icons.trending_up_rounded,
      'bg': const Color(0xFFE8F5E9),
      'fg': const Color(0xFF2E7D32),
    };
  }
}

class CategorieRevenu {
  final int id;
  final String nom;

  const CategorieRevenu({required this.id, required this.nom});

  factory CategorieRevenu.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    return CategorieRevenu(
      id: id is int ? id : (id is num ? id.toInt() : int.tryParse('$id') ?? 0),
      nom: json['nom']?.toString().trim() ?? '',
    );
  }
}
