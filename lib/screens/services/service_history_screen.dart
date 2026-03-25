import 'package:flutter/material.dart';
import '../../../models/user.dart';

class ServiceHistoryScreen extends StatefulWidget {
  final User user;

  const ServiceHistoryScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ServiceHistoryScreenState createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  final Color _bleuFonce = Color(0xFF0D1F3C);
  final Color _bleuMoyen = Color(0xFF1A3A6B);
  final Color _vertMoyen = Color(0xFF4CAF50);
  final Color _orange = Color(0xFFFF9800);
  final Color _rouge = Color(0xFFF44336);

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
          'HISTORIQUE DES SERVICES',
          style: TextStyle(
            color: _bleuFonce,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Statistiques
              Container(
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
                    _buildStatItem('8', 'Total', Colors.white),
                    _buildStatItem('3', 'En cours', _orange),
                    _buildStatItem('5', 'Terminés', Colors.green),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Liste des demandes
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return _buildHistoryItem(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
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

  Widget _buildHistoryItem(int index) {
    final statuses = ['En attente', 'En cours', 'Terminé'];
    final colors = [Colors.orange, Colors.blue, Colors.green];
    final types = ['Plomberie', 'Nettoyage', 'Réparation', 'Maintenance'];

    return Container(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                types[index % types.length],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _bleuFonce,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors[index % colors.length].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statuses[index % statuses.length],
                  style: TextStyle(
                    fontSize: 11,
                    color: colors[index % colors.length],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Demande du 15/03/2026',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Description de la demande...',
            style: TextStyle(
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}