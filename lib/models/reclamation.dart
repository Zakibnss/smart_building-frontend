class Reclamation {
  final int id;
  final String titre;
  final String description;
  final String categorie;
  final String statut;
  final DateTime dateCreation;
  final DateTime? dateResolution;

  Reclamation({
    required this.id,
    required this.titre,
    required this.description,
    required this.categorie,
    required this.statut,
    required this.dateCreation,
    this.dateResolution,
  });

  factory Reclamation.fromJson(Map<String, dynamic> json) {
    return Reclamation(
      id: json['id'],
      titre: json['titre'],
      description: json['description'] ?? '',
      categorie: json['categorie'] ?? '',
      statut: json['statut'],
      dateCreation: DateTime.parse(json['date_creation']),
      dateResolution: json['date_resolution'] != null 
          ? DateTime.parse(json['date_resolution']) 
          : null,
    );
  }
}