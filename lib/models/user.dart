class User {
  final int id;
  final String nom;
  final String email;
  final String role;
  final int complexId;
  final String? complexNom;
  final String? telephone;
  final int? residentId;
  final String? numeroAppartement;
  final String? batiment;

  User({
    required this.id,
    required this.nom,
    required this.email,
    required this.role,
    required this.complexId,
    this.complexNom,
    this.telephone,
    this.residentId,
    this.numeroAppartement,
    this.batiment,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Fonction utilitaire pour convertir en int de façon sécurisée
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return User(
      id: toInt(json['id']),
      nom: json['nom'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      complexId: toInt(json['complex_id']),
      complexNom: json['complex_nom'],
      telephone: json['telephone'],
      residentId: toInt(json['resident_id']),
      numeroAppartement: json['numero_appartement'],
      batiment: json['batiment'],
    );
  }
}
