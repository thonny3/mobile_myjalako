class AuthUser {
  final int idUser;
  final String nom;
  final String prenom;
  final String email;
  final String devise;

  const AuthUser({
    required this.idUser,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.devise,
  });

  String get displayName {
    final p = prenom.trim();
    final n = nom.trim();
    if (p.isEmpty && n.isEmpty) return 'Utilisateur';
    if (p.isEmpty) return n;
    if (n.isEmpty) return p;
    return '$p $n';
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      idUser: _parseId(json['id_user']),
      nom: _parseString(json['nom']),
      prenom: _parseString(json['prenom']),
      email: _parseString(json['email']),
      devise: _parseString(json['devise']).isEmpty ? 'MGA' : _parseString(json['devise']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_user': idUser,
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'devise': devise,
      };
}
