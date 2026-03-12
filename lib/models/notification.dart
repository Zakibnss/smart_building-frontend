class Notification {
  final int id;
  final String titre;
  final String contenu;
  final String type;
  final bool estLu;
  final DateTime dateEnvoi;

  Notification({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.type,
    required this.estLu,
    required this.dateEnvoi,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      titre: json['titre'] ?? '',
      contenu: json['contenu'],
      type: json['type'],
      estLu: json['est_lu'] == 1,
      dateEnvoi: DateTime.parse(json['date_envoi']),
    );
  }
}