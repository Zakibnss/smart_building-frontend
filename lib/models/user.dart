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
    return User(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
      role: json['role'],
      complexId: json['complex_id'],
      complexNom: json['complex_nom'],
      telephone: json['telephone'],
      residentId: json['resident_id'],
      numeroAppartement: json['numero_appartement'],
      batiment: json['batiment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'role': role,
      'complex_id': complexId,
      'complex_nom': complexNom,
      'telephone': telephone,
      'resident_id': residentId,
      'numero_appartement': numeroAppartement,
      'batiment': batiment,
    };
  }
}