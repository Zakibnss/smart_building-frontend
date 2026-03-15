import 'package:flutter/material.dart';
import 'package:smart_residence/models/resident.dart';
import 'package:smart_residence/services/api_service.dart';
import 'add_resident_screen.dart';
import 'edit_resident_screen.dart';

class ResidentsListScreen extends StatefulWidget {
  @override
  _ResidentsListScreenState createState() => _ResidentsListScreenState();
}

class _ResidentsListScreenState extends State<ResidentsListScreen> {
  List<Resident> _residents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadResidents();
  }

  Future<void> _loadResidents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final residents = await ApiService.getResidents();
      setState(() {
        _residents = residents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de chargement: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteResident(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce résident ?'),
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
        await ApiService.deleteResident(id);
        _loadResidents();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Résident supprimé avec succès')),
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
          'Gestion des résidents',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF0F2B4B),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadResidents,
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
                  Text(
                    'Liste des résidents',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F2B4B),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddResidentScreen(),
                        ),
                      );
                      if (result == true) {
                        _loadResidents();
                      }
                    },
                    icon: Icon(Icons.add),
                    label: Text('Ajouter un résident'),
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
            // Corps avec la liste
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
                                onPressed: _loadResidents,
                                child: Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                      : _residents.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Aucun résident trouvé',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Cliquez sur "Ajouter un résident" pour commencer',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: _residents.length,
                              itemBuilder: (context, index) {
                                final resident = _residents[index];
                                return _buildResidentCard(resident);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResidentCard(Resident resident) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de la carte
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFF0F2B4B).withOpacity(0.1),
                    child: Text(
                      resident.nom.isNotEmpty ? resident.nom[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F2B4B),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resident.nom,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.apartment,
                                size: 16, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(
                              'App: ${resident.numeroAppartement}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.location_on,
                                size: 16, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(
                              'Bât: ${resident.batiment}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        if (resident.parkingId != null)
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(Icons.local_parking,
                                    size: 16, color: Colors.grey[600]),
                                SizedBox(width: 4),
                                Text(
                                  'Place: P${resident.parkingId}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Informations de contact
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.email, 'Email', resident.email),
                    Divider(height: 8),
                    _buildInfoRow(Icons.phone, 'Téléphone', resident.telephone),
                  ],
                ),
              ),
              SizedBox(height: 12),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditResidentScreen(
                            resident: resident,
                          ),
                        ),
                      );
                      if (result == true) {
                        _loadResidents();
                      }
                    },
                    icon: Icon(Icons.edit, color: Color(0xFF2A6FA5)),
                    label: Text('Modifier'),
                  ),
                  SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _deleteResident(resident.id),
                    icon: Icon(Icons.delete, color: Colors.red),
                    label: Text('Supprimer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}