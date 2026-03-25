// lib/models/archive.dart
class ResidentArchive {
  final int id;
  final String nom;
  final String email;
  final String telephone;
  final String appartement;
  final String batiment;
  final DateTime dateCreation;
  final DateTime dateSuppression;
  final String raisonSuppression;
  final String? supprimePar;
  final List<Map<String, dynamic>> reclamations;
  final List<Map<String, dynamic>> colis;
  final List<Map<String, dynamic>> services;
  final List<Map<String, dynamic>> accesVisiteurs;

  ResidentArchive({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.appartement,
    required this.batiment,
    required this.dateCreation,
    required this.dateSuppression,
    required this.raisonSuppression,
    this.supprimePar,
    required this.reclamations,
    required this.colis,
    required this.services,
    required this.accesVisiteurs,
  });

  factory ResidentArchive.fromJson(Map<String, dynamic> json) {
    return ResidentArchive(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      appartement: json['appartement'] ?? '',
      batiment: json['batiment'] ?? '',
      dateCreation: DateTime.parse(json['date_creation']),
      dateSuppression: DateTime.parse(json['date_suppression']),
      raisonSuppression: json['raison_suppression'] ?? '',
      supprimePar: json['supprime_par'],
      reclamations: List<Map<String, dynamic>>.from(json['reclamations'] ?? []),
      colis: List<Map<String, dynamic>>.from(json['colis'] ?? []),
      services: List<Map<String, dynamic>>.from(json['services'] ?? []),
      accesVisiteurs: List<Map<String, dynamic>>.from(json['acces_visiteurs'] ?? []),
    );
  }
}