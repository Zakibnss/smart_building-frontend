import 'package:flutter/material.dart';
import 'package:smart_residence/models/user.dart';
import 'package:smart_residence/services/api_service.dart';
import 'technician_detail_screen.dart';
import 'add_technician_screen.dart';
import 'edit_technician_screen.dart';

class TechniciansListScreen extends StatefulWidget {
  @override
  _TechniciansListScreenState createState() => _TechniciansListScreenState();
}

class _TechniciansListScreenState extends State<TechniciansListScreen> {
  List<User> _technicians = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Liste des spécialités pour l'affichage
  final List<String> _specialites = [
    'Électricien', 'Plombier', 'Maintenance', 'Nettoyage', 'Jardinier', 'Sécurité'
  ];

  @override
  void initState() {
    super.initState();
    _loadTechnicians();
  }

  Future<void> _loadTechnicians() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final technicians = await ApiService.getTechnicians();
      setState(() {
        _technicians = technicians;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de chargement: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTechnician(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce technicien ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteTechnician(id);
        _loadTechnicians();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Technicien supprimé avec succès')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestion des techniciens',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF0F2B4B),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTechnicians,
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFF5F7FA),
        child: Column(
          children: [
            // En-tête avec bouton d'ajout
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Liste des techniciens',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F2B4B),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Gestion complète (ajout, modification, suppression)',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTechnicianScreen(),
                        ),
                      );
                      if (result == true) {
                        _loadTechnicians();
                      }
                    },
                    icon: Icon(Icons.add),
                    label: Text('Ajouter technicien'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2A6FA5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Liste
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.red, size: 60),
                              SizedBox(height: 16),
                              Text(_errorMessage!),
                              ElevatedButton(
                                onPressed: _loadTechnicians,
                                child: Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                      : _technicians.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.build_outlined,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Aucun technicien trouvé',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Cliquez sur "Ajouter technicien" pour commencer',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: _technicians.length,
                              itemBuilder: (context, index) {
                                final tech = _technicians[index];
                                return _buildTechnicianCard(tech);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianCard(User tech) {
    // Utiliser la spécialité du modèle ou en assigner une par défaut
    final String specialite = tech.specialite ?? 
        _specialites[tech.id % _specialites.length];
    
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

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar avec icône selon spécialité
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  getIconForSpeciality(specialite),
                  color: color,
                  size: 30,
                ),
              ),
              SizedBox(width: 16),
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tech.nom,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        specialite,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.email, size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            tech.email,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (tech.telephone != null && tech.telephone!.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            tech.telephone!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Boutons d'action
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.visibility, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TechnicianDetailScreen(technician: tech),
                        ),
                      );
                    },
                    tooltip: 'Voir détails',
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Color(0xFF2A6FA5), size: 20),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTechnicianScreen(technician: tech),
                            ),
                          );
                          if (result == true) {
                            _loadTechnicians();
                          }
                        },
                        tooltip: 'Modifier',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () => _deleteTechnician(tech.id),
                        tooltip: 'Supprimer',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}