class ParkingSpot {
  final int id;
  final String numeroPlace;
  final String type;
  final String statut;
  final String? residentNom;

  ParkingSpot({
    required this.id,
    required this.numeroPlace,
    required this.type,
    required this.statut,
    this.residentNom,
  });

  factory ParkingSpot.fromJson(Map<String, dynamic> json) {
    return ParkingSpot(
      id: json['id'],
      numeroPlace: json['numero_place'],
      type: json['type'],
      statut: json['statut'],
      residentNom: json['resident_nom'],
    );
  }
}