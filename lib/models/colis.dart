class Colis {
  final int id;
  final String description;
  final String typeColis;
  final String statut;
  final DateTime dateArrivee;
  final DateTime? dateRemise;
  final String? codeRetrait;
  final String? agentNom;

  Colis({
    required this.id,
    required this.description,
    required this.typeColis,
    required this.statut,
    required this.dateArrivee,
    this.dateRemise,
    this.codeRetrait,
    this.agentNom,
  });

  factory Colis.fromJson(Map<String, dynamic> json) {
    return Colis(
      id: json['id'],
      description: json['description'] ?? '',
      typeColis: json['type_colis'],
      statut: json['statut'],
      dateArrivee: DateTime.parse(json['date_arrivee']),
      dateRemise: json['date_remise'] != null 
          ? DateTime.parse(json['date_remise']) 
          : null,
      codeRetrait: json['code_retrait'],
      agentNom: json['agent_nom'],
    );
  }
}