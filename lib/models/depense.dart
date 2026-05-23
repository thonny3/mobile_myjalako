import 'package:flutter/material.dart';

class Depense {
  final int idDepense;
  final int? idUser;
  final double montant;
  final DateTime? dateDepense;
  final String description;
  final int? idCategorieDepense;
  final int? idCompte;
  final String? categorieNom;
  final String? compteNom;

  const Depense({
    required this.idDepense,
    this.idUser,
    required this.montant,
    this.dateDepense,
    required this.description,
    this.idCategorieDepense,
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

  Depense copyWith({
    double? montant,
    DateTime? dateDepense,
    String? description,
    int? idCategorieDepense,
    int? idCompte,
    String? categorieNom,
    String? compteNom,
  }) {
    return Depense(
      idDepense: idDepense,
      idUser: idUser,
      montant: montant ?? this.montant,
      dateDepense: dateDepense ?? this.dateDepense,
      description: description ?? this.description,
      idCategorieDepense: idCategorieDepense ?? this.idCategorieDepense,
      idCompte: idCompte ?? this.idCompte,
      categorieNom: categorieNom ?? this.categorieNom,
      compteNom: compteNom ?? this.compteNom,
    );
  }

  factory Depense.fromJson(Map<String, dynamic> json) {
    return Depense(
      idDepense: _parseId(json['id_depense']),
      idUser: json['id_user'] != null ? _parseId(json['id_user']) : null,
      montant: _parseMontant(json['montant']),
      dateDepense: _parseDate(json['date_depense']),
      description: json['description']?.toString().trim() ?? '',
      idCategorieDepense: json['id_categorie_depense'] != null
          ? _parseId(json['id_categorie_depense'])
          : null,
      idCompte: json['id_compte'] != null ? _parseId(json['id_compte']) : null,
      categorieNom: json['categorie_nom']?.toString(),
      compteNom: json['compte_nom']?.toString(),
    );
  }

  bool get isCurrentMonth {
    final d = dateDepense;
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month;
  }

  String get subtitle {
    final parts = <String>[];
    if (dateDepense != null) {
      final d = dateDepense!;
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
    return parts.isEmpty ? 'Dépense' : parts.join(' · ');
  }

  Map<String, dynamic> toUiMap() {
    return {
      'id_depense': idDepense,
      'title': description.isNotEmpty ? description : 'Dépense',
      'subtitle': subtitle,
      'amount': montant.round(),
      'icon': Icons.trending_down_rounded,
      'bg': const Color(0xFFFFEBEE),
      'fg': const Color(0xFFD32F2F),
    };
  }
}

class CategorieDepense {
  final int id;
  final String nom;

  const CategorieDepense({required this.id, required this.nom});

  factory CategorieDepense.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    return CategorieDepense(
      id: id is int ? id : (id is num ? id.toInt() : int.tryParse('$id') ?? 0),
      nom: json['nom']?.toString().trim() ?? '',
    );
  }
}
