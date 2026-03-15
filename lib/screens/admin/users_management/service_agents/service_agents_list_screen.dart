import 'package:flutter/material.dart';
import 'package:smart_residence/models/user.dart';
import 'package:smart_residence/services/api_service.dart';
import 'add_service_agent_screen.dart';
import 'edit_service_agent_screen.dart';

class ServiceAgentsListScreen extends StatefulWidget {
  @override
  _ServiceAgentsListScreenState createState() => _ServiceAgentsListScreenState();
}

class _ServiceAgentsListScreenState extends State<ServiceAgentsListScreen> {
  List<User> _agents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final agents = await ApiService.getServiceAgents();
      setState(() {
        _agents = agents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de chargement: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAgent(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Êtes-vous sûr de vouloir supprimer cet agent ?'),
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
        await ApiService.deleteServiceAgent(id);
        _loadAgents();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Agent supprimé avec succès')),
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
          'Gestion des agents de service',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF0F2B4B),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAgents,
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFF5F7FA),
        child: Column(
          children: [
            // En-tête avec boutons
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Liste des agents de service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F2B4B),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddServiceAgentScreen(),
                              ),
                            );
                            if (result == true) {
                              _loadAgents();
                            }
                          },
                          icon: Icon(Icons.add),
                          label: Text('Ajouter agent de service'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2A6FA5),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
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
                                onPressed: _loadAgents,
                                child: Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                      : _agents.isEmpty
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
                                    'Aucun agent trouvé',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: _agents.length,
                              itemBuilder: (context, index) {
                                final agent = _agents[index];
                                return _buildAgentCard(agent);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentCard(User agent) {
    // Déterminer la spécialité (à adapter selon votre modèle)
    final specialite = agent.specialite ?? 'Maintenance';
    
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
        default:
          return Icons.handyman;
      }
    }

    final color = getColorForSpeciality(specialite);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(getIconForSpeciality(specialite), color: color),
        ),
        title: Text(
          agent.nom,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(agent.email),
            if (agent.telephone != null) Text(agent.telephone!),
            Container(
              margin: EdgeInsets.only(top: 4),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                specialite,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Color(0xFF2A6FA5)),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditServiceAgentScreen(agent: agent),
                  ),
                );
                if (result == true) {
                  _loadAgents();
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteAgent(agent.id),
            ),
          ],
        ),
      ),
    );
  }
}