import 'package:flutter/material.dart';
import 'package:smart_residence/models/user.dart';




class TechnicianDetailScreen extends StatelessWidget {
  final User technician;

  const TechnicianDetailScreen({Key? key, required this.technician}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Liste des spécialités
    final List<String> _specialites = [
      'Électricien', 'Plombier', 'Maintenance', 'Nettoyage', 'Jardinier', 'Sécurité'
    ];
    
    final String specialite = technician.specialite ?? 
        _specialites[technician.id % _specialites.length];
    
    Color getColorForSpeciality(String spec) {
      switch (spec) {
        case 'Électricien':
          return Colors.amber;
        case 'Plombier':
          return Colors.blue;
        case 'Maintenance':
          return Colors.green;
        case 'Nettoyage':
          return Colors.purple;
        case 'Jardinier':
          return Colors.teal;
        case 'Sécurité':
          return Colors.red;
        default:
          return Colors.orange;
      }
    }

    IconData getIconForSpeciality(String spec) {
      switch (spec) {
        case 'Électricien':
          return Icons.electrical_services;
        case 'Plombier':
          return Icons.plumbing;
        case 'Maintenance':
          return Icons.build;
        case 'Nettoyage':
          return Icons.cleaning_services;
        case 'Jardinier':
          return Icons.yard;
        case 'Sécurité':
          return Icons.security;
        default:
          return Icons.handyman;
      }
    }

    final color = getColorForSpeciality(specialite);

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du technicien'),
        backgroundColor: color,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Carte d'identité
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        getIconForSpeciality(specialite),
                        color: color,
                        size: 50,
                      ),
                    ),
                    SizedBox(height: 16),
                    // Nom
                    Text(
                      technician.nom,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Spécialité
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        specialite,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Informations de contact
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInfoTile(
                      icon: Icons.email,
                      color: Colors.blue,
                      label: 'Email',
                      value: technician.email,
                    ),
                    Divider(),
                    _buildInfoTile(
                      icon: Icons.phone,
                      color: Colors.green,
                      label: 'Téléphone',
                      value: technician.telephone ?? 'Non renseigné',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Note de consultation
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Consultation uniquement - Les informations ne peuvent pas être modifiées',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}