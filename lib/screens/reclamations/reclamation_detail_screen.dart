import 'package:flutter/material.dart';
import '../../models/user.dart';
import 'reclamation_feedback_screen.dart';

class ReclamationDetailScreen extends StatelessWidget {
  final User user;
  final Map<String, dynamic> reclamation;

   ReclamationDetailScreen({
    Key? key,
    required this.user,
    required this.reclamation,
  }) : super(key: key);

  final Color _bleuFonce = Color(0xFF0D1F3C);
  final Color _bleuMoyen = Color(0xFF1A3A6B);
  final Color _vertMoyen = Color(0xFF4CAF50);
  final Color _orange = Color(0xFFFF9800);
  final Color _rouge = Color(0xFFF44336);

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
        return 'En cours de traitement';
      case 'resolue':
        return 'Résolue';
      default:
        return reclamation['statut'];
    }
  }

  String getStatusIcon() {
    switch (reclamation['statut']) {
      case 'en_attente':
        return '⏳';
      case 'en_cours':
        return '🔄';
      case 'resolue':
        return '✅';
      default:
        return '📝';
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

  String formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
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
          'DÉTAIL RÉCLAMATION',
          style: TextStyle(
            color: _bleuFonce,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (reclamation['statut'] == 'resolue')
            IconButton(
              icon: Icon(Icons.feedback, color: _vertMoyen),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReclamationFeedbackScreen(
                      user: user,
                      reclamationId: reclamation['id'],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête avec statut
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        getStatusIcon(),
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    getStatusText(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: getStatusColor(),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Réclamation #${reclamation['id']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations principales
                  Container(
                    padding: EdgeInsets.all(20),
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
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: getCategoryColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                getCategoryIcon(),
                                color: getCategoryColor(),
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Type de problème',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    reclamation['categorie'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _bleuFonce,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 24),

                        // Titre
                        Text(
                          'Titre',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          reclamation['titre'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _bleuFonce,
                          ),
                        ),
                        Divider(height: 24),

                        // Description
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          reclamation['description'],
                          style: TextStyle(
                            fontSize: 15,
                            color: _bleuFonce,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Informations supplémentaires
                  Container(
                    padding: EdgeInsets.all(20),
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
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.location_on,
                          'Lieu du problème',
                          reclamation['lieu'],
                        ),
                        Divider(),
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Date de création',
                          formatDate(reclamation['date_creation']),
                        ),
                        if (reclamation['date_resolution'] != null) ...[
                          Divider(),
                          _buildInfoRow(
                            Icons.check_circle,
                            'Date de résolution',
                            formatDate(reclamation['date_resolution']),
                            color: _vertMoyen,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Timeline (optionnelle)
                  if (reclamation['statut'] != 'en_attente')
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      padding: EdgeInsets.all(20),
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
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Suivi de la réclamation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _bleuFonce,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildTimelineItem(
                            'Création',
                            formatDate(reclamation['date_creation']),
                            Icons.add_circle,
                            Colors.green,
                            isFirst: true,
                          ),
                          if (reclamation['statut'] == 'en_cours')
                            _buildTimelineItem(
                              'Prise en charge',
                              formatDate(reclamation['date_creation']),
                              Icons.handshake,
                              _bleuMoyen,
                            ),
                          if (reclamation['statut'] == 'resolue') ...[
                            _buildTimelineItem(
                              'Prise en charge',
                              formatDate(reclamation['date_creation']),
                              Icons.handshake,
                              _bleuMoyen,
                            ),
                            _buildTimelineItem(
                              'Résolution',
                              formatDate(reclamation['date_resolution']),
                              Icons.check_circle,
                              _vertMoyen,
                              isLast: true,
                            ),
                          ],
                        ],
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

  Widget _buildInfoRow(IconData icon, String label, String value, {Color color = Colors.grey}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _bleuFonce,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String date, IconData icon, Color color,
      {bool isFirst = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: Colors.grey[300],
              ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[300],
              ),
          ],
        ),
        SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: isFirst ? 0 : 20, bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _bleuFonce,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}