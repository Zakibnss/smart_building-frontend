class Reclamation {
  final int id;
  final int residentId;
  final String? residentNom;
  final String? appartement;
  final String titre;
  final String description;
  final String? categorie;
  final String? lieu;
  final String statut;
  final DateTime dateCreation;
  final DateTime? dateResolution;
  final int? assigneAId;
  final String? assigneANom;
  final String? feedback;
  final int? note;

  Reclamation({
    required this.id,
    required this.residentId,
    this.residentNom,
    this.appartement,
    required this.titre,
    required this.description,
    this.categorie,
    this.lieu,
    required this.statut,
    required this.dateCreation,
    this.dateResolution,
    this.assigneAId,
    this.assigneANom,
    this.feedback,
    this.note,
  });

  // Fonction pour parser les dates MySQL (format: "2026-03-15 01:12:30")
  static DateTime _parseMySQLDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime.now();
    
    try {
      // Format MySQL: "2026-03-15 01:12:30"
      if (dateStr.contains(' ')) {
        List<String> parts = dateStr.split(' ');
        if (parts.length == 2) {
          List<String> dateParts = parts[0].split('-');
          List<String> timeParts = parts[1].split(':');
          
          if (dateParts.length == 3 && timeParts.isNotEmpty) {
            return DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
              int.parse(timeParts[0]),
              int.parse(timeParts[1]),
              timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
            );
          }
        }
      }
      
      // Format ISO standard
      return DateTime.parse(dateStr);
    } catch (e) {
      print('❌ Erreur parsing date: $dateStr - $e');
      return DateTime.now();
    }
  }

  factory Reclamation.fromJson(Map<String, dynamic> json) {
    return Reclamation(
      id: json['id'] ?? 0,
      residentId: json['resident_id'] ?? 0,
      residentNom: json['resident_nom']?.toString() ?? 
                   json['nom_resident']?.toString() ?? 
                   'Inconnu',
      appartement: json['appartement']?.toString() ?? 
                   json['numero_appartement']?.toString() ?? 
                   '?',
      titre: json['titre']?.toString() ?? 'Sans titre',
      description: json['description']?.toString() ?? '',
      categorie: json['categorie']?.toString(),
      lieu: json['lieu']?.toString(),
      statut: json['statut']?.toString() ?? 'en_attente',
      dateCreation: _parseMySQLDate(json['date_creation']),
      dateResolution: json['date_resolution'] != null 
          ? _parseMySQLDate(json['date_resolution']) 
          : null,
      assigneAId: json['assigne_a'],
      assigneANom: json['assigne_a_nom']?.toString(),
      feedback: json['feedback']?.toString(),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resident_id': residentId,
      'titre': titre,
      'description': description,
      'categorie': categorie,
      'lieu': lieu,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_resolution': dateResolution?.toIso8601String(),
      'assigne_a': assigneAId,
      'feedback': feedback,
      'note': note,
    };
  }
}