import 'package:flutter/material.dart';
import '../../models/user.dart';
import 'reclamation_detail_screen.dart';
import 'create_reclamation_screen.dart';

class ReclamationsListScreen extends StatefulWidget {
  final User user;

  const ReclamationsListScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ReclamationsListScreenState createState() => _ReclamationsListScreenState();
}

class _ReclamationsListScreenState extends State<ReclamationsListScreen> {
  final Color _bleuFonce = Color(0xFF0D1F3C);
  final Color _bleuMoyen = Color(0xFF1A3A6B);
  final Color _vertMoyen = Color(0xFF4CAF50);
  final Color _orange = Color(0xFFFF9800);
  final Color _rouge = Color(0xFFF44336);
  final Color _violet = Color(0xFF9C27B0);

  // Données simulées pour l'exemple
  List<Map<String, dynamic>> _reclamations = [];

  @override
  void initState() {
    super.initState();
    _loadReclamations();
  }

  Future<void> _loadReclamations() async {
    // Simuler un chargement depuis l'API
    await Future.delayed(Duration(seconds: 1));
    
    setState(() {
      _reclamations = [
        {
          'id': 1,
          'titre': 'Problème électricité',
          'description': 'Les lumières du couloir ne fonctionnent pas',
          'categorie': 'Électricité',
          'lieu': 'Complexe',
          'statut': 'en_cours',
          'date_creation': '2026-03-15 14:30:00',
          'date_resolution': null,
        },
        {
          'id': 2,
          'titre': 'Fuite d\'eau',
          'description': 'Fuite dans la salle de bain',
          'categorie': 'Eau',
          'lieu': 'Maison',
          'statut': 'en_attente',
          'date_creation': '2026-03-14 10:15:00',
          'date_resolution': null,
        },
        {
          'id': 3,
          'titre': 'Bruit excessif',
          'description': 'Bruit la nuit',
          'categorie': 'Service',
          'lieu': 'Complexe',
          'statut': 'resolue',
          'date_creation': '2026-03-10 09:00:00',
          'date_resolution': '2026-03-12 16:30:00',
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _bleuFonce),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'MES RÉCLAMATIONS',
          style: TextStyle(
            color: _bleuFonce,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle, color: _bleuMoyen, size: 28),
            onPressed: () => _navigateToCreateReclamation(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistiques rapides
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_bleuMoyen, _vertMoyen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  _reclamations.where((r) => r['statut'] == 'en_attente').length.toString(),
                  'En attente',
                  _orange,
                ),
                _buildStatItem(
                  _reclamations.where((r) => r['statut'] == 'en_cours').length.toString(),
                  'En cours',
                  _bleuMoyen,
                ),
                _buildStatItem(
                  _reclamations.where((r) => r['statut'] == 'resolue').length.toString(),
                  'Résolues',
                  _vertMoyen,
                ),
              ],
            ),
          ),

          // Liste des réclamations
          Expanded(
            child: _reclamations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aucune réclamation',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Appuyez sur + pour créer une réclamation',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _reclamations.length,
                    itemBuilder: (context, index) {
                      return _buildReclamationCard(_reclamations[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateReclamation,
        backgroundColor: _vertMoyen,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildReclamationCard(Map<String, dynamic> reclamation) {
    Color getStatusColor() {
      switch (reclamation['statut']) {
        case 'en_attente':
          return _orange;
        case 'en_cours':
          return _bleuMoyen;
        case 'resolue':
          return _vertMoyen;
        default:
          return Colors.grey;
      }
    }

    String getStatusText() {
      switch (reclamation['statut']) {
        case 'en_attente':
          return 'En attente';
        case 'en_cours':
          return 'En cours';
        case 'resolue':
          return 'Résolue';
        default:
          return reclamation['statut'];
      }
    }

    IconData getCategoryIcon() {
      switch (reclamation['categorie']) {
        case 'Eau':
          return Icons.water_drop;
        case 'Électricité':
          return Icons.electrical_services;
        case 'Parking':
          return Icons.local_parking;
        case 'Service':
          return Icons.build;
        case 'Ascenseur':
          return Icons.elevator;
        default:
          return Icons.report_problem;
      }
    }

    Color getCategoryColor() {
      switch (reclamation['categorie']) {
        case 'Eau':
          return Colors.blue;
        case 'Électricité':
          return Colors.amber;
        case 'Parking':
          return Colors.green;
        case 'Service':
          return Colors.purple;
        case 'Ascenseur':
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    String getFormattedDate(String dateStr) {
      try {
        DateTime date = DateTime.parse(dateStr);
        return '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        return dateStr;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReclamationDetailScreen(
              user: widget.user,
              reclamation: reclamation,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border(
            left: BorderSide(
              color: getStatusColor(),
              width: 4,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: getCategoryColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    getCategoryIcon(),
                    color: getCategoryColor(),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reclamation['titre'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _bleuFonce,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        reclamation['description'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 4),
                    Text(
                      getFormattedDate(reclamation['date_creation']),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 4),
                    Text(
                      reclamation['lieu'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    getStatusText(),
                    style: TextStyle(
                      fontSize: 11,
                      color: getStatusColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateReclamation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateReclamationScreen(user: widget.user),
      ),
    ).then((value) {
      if (value == true) {
        _loadReclamations();
      }
    });
  }
}