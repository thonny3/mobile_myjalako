class TransfertHistorique {
  final int id;
  final String type;
  final double montant;
  final DateTime? dateTransfert;
  final String? sourceNom;
  final String? cibleNom;

  const TransfertHistorique({
    required this.id,
    required this.type,
    required this.montant,
    this.dateTransfert,
    this.sourceNom,
    this.cibleNom,
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
    return DateTime.tryParse(value.toString().trim());
  }

  factory TransfertHistorique.fromJson(Map<String, dynamic> json) {
    final id = json['id_transfert'] ?? json['id'];
    return TransfertHistorique(
      id: _parseId(id),
      type: json['type']?.toString() ?? '',
      montant: _parseMontant(json['montant']),
      dateTransfert: _parseDate(json['date_transfert']),
      sourceNom: json['source_nom']?.toString(),
      cibleNom: json['cible_nom']?.toString(),
    );
  }

  String get label {
    switch (type) {
      case 'compte_to_compte':
        return 'Virement entre comptes';
      case 'compte_to_objectif':
        return 'Versement objectif';
      case 'objectif_to_compte':
        return 'Retrait objectif';
      default:
        return 'Transfert';
    }
  }

  String get routeLabel {
    final from = sourceNom ?? 'Source';
    final to = cibleNom ?? 'Destination';
    return '$from → $to';
  }

  String get dateLabel {
    final d = dateTransfert;
    if (d == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final time =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    if (day == today) return "Aujourd'hui, $time";
    final yesterday = today.subtract(const Duration(days: 1));
    if (day == yesterday) return 'Hier, $time';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}, $time';
  }
}
