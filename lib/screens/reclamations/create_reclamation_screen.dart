import 'package:flutter/material.dart';
import '../../models/user.dart';

class CreateReclamationScreen extends StatefulWidget {
  final User user;

  const CreateReclamationScreen({Key? key, required this.user}) : super(key: key);

  @override
  _CreateReclamationScreenState createState() => _CreateReclamationScreenState();
}

class _CreateReclamationScreenState extends State<CreateReclamationScreen> {
  String _selectedType = '';
  String _selectedLieu = 'Maison';
  final TextEditingController _descriptionController = TextEditingController();

  final List<Map<String, dynamic>> _types = [
    {'icon': Icons.water_drop, 'label': 'Eau', 'color': Colors.blue},
    {'icon': Icons.electrical_services, 'label': 'Électricité', 'color': Colors.amber},
    {'icon': Icons.local_parking, 'label': 'Parking', 'color': Colors.green},
    {'icon': Icons.build, 'label': 'Service', 'color': Colors.purple},
    {'icon': Icons.elevator, 'label': 'Ascenseur', 'color': Colors.orange},
    {'icon': Icons.more_horiz, 'label': 'Autre', 'color': Colors.grey},
  ];

  final Color _bleuFonce = Color(0xFF0D1F3C);
  final Color _bleuMoyen = Color(0xFF1A3A6B);
  final Color _vertMoyen = Color(0xFF4CAF50);

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
          'FAIRE RÉCLAMATION',
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
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type de problème
              Text(
                'Type de problème',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _bleuFonce,
                ),
              ),
              SizedBox(height: 16),

              // Grille des types
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: _types.length,
                itemBuilder: (context, index) {
                  final type = _types[index];
                  final isSelected = _selectedType == type['label'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = type['label'];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? type['color'].withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? type['color'] : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            type['icon'],
                            color: isSelected ? type['color'] : Colors.grey[600],
                            size: 28,
                          ),
                          SizedBox(height: 8),
                          Text(
                            type['label'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? type['color'] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 24),

              // Description
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _bleuFonce,
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Décrivez le problème en détail...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Lieu du problème
              Text(
                'Lieu du problème',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _bleuFonce,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildLieuOption('Maison', Icons.home),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildLieuOption('Complexe', Icons.apartment),
                  ),
                ],
              ),

              SizedBox(height: 32),

              // Bouton Envoyer
              ElevatedButton(
                onPressed: _selectedType.isEmpty
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Réclamation envoyée avec succès!'),
                            backgroundColor: _vertMoyen,
                          ),
                        );
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _vertMoyen,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'ENVOYER',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLieuOption(String lieu, IconData icon) {
    final isSelected = _selectedLieu == lieu;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLieu = lieu;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _vertMoyen.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _vertMoyen : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? _vertMoyen : Colors.grey[600],
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              lieu,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? _vertMoyen : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}