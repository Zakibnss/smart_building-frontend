class Resident {
  final int id;
  final String nom;
  final String email;
  final String telephone;
  final String numeroAppartement;
  final String batiment;
  final int? parkingId;

  Resident({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.numeroAppartement,
    required this.batiment,
    this.parkingId,
  });

  factory Resident.fromJson(Map<String, dynamic> json) {
    return Resident(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
      telephone: json['telephone'] ?? '',
      numeroAppartement: json['numero_appartement'],
      batiment: json['batiment'],
      parkingId: json['parking_id'],
    );
  }
}