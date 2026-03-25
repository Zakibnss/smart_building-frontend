import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/reclamation.dart';
import '../../models/user.dart';

class TransferReclamationScreen extends StatefulWidget {
  final Reclamation reclamation;

  const TransferReclamationScreen({Key? key, required this.reclamation}) : super(key: key);

  @override
  _TransferReclamationScreenState createState() => _TransferReclamationScreenState();
}

class _TransferReclamationScreenState extends State<TransferReclamationScreen> {
  List<User> _agents = [];
  User? _selectedAgent;
  String _selectedPriorite = 'normale';
  bool _isLoading = true;
  bool _isTransferring = false;

  final Color _bleuFonce = const Color(0xFF0D1F3C);
  final Color _bleuMoyen = const Color(0xFF1A3A6B);
  final Color _vertMoyen = const Color(0xFF4CAF50);
  final Color _orange = const Color(0xFFFF9800);
  final Color _rouge = const Color(0xFFF44336);

  final List<Map<String, dynamic>> _priorites = [
    {'value': 'basse', 'label': 'Basse', 'color': Colors.grey},
    {'value': 'normale', 'label': 'Normale', 'color': Colors.blue},
    {'value': 'haute', 'label': 'Haute', 'color': Colors.orange},
    {'value': 'urgente', 'label': 'Urgente', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    setState(() => _isLoading = true);

    try {
      final agents = await ApiService.getServiceAgents();
      setState(() {
        _agents = agents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: _rouge,
        ),
      );
    }
  }

  Future<void> _transferer() async {
    if (_selectedAgent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un agent'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isTransferring = true);

    try {
      final response = await ApiService.transferReclamationToMission(
        widget.reclamation.id,
        _selectedAgent!.id,
        _selectedPriorite,
      );

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Réclamation transférée avec succès!'),
            backgroundColor: _vertMoyen,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Erreur'),
            backgroundColor: _rouge,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: _rouge,
        ),
      );
    } finally {
      setState(() => _isTransferring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Transférer en mission',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _bleuFonce,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Détails de la réclamation
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Réclamation à transférer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Titre',
                          widget.reclamation.titre,
                          Icons.title,
                        ),
                        const Divider(),
                        _buildDetailRow(
                          'Description',
                          widget.reclamation.description,
                          Icons.description,
                        ),
                        const Divider(),
                        _buildDetailRow(
                          'Résident',
                          widget.reclamation.residentNom ?? 'Inconnu',
                          Icons.person,
                        ),
                        const Divider(),
                        _buildDetailRow(
                          'Appartement',
                          widget.reclamation.appartement ?? '?',
                          Icons.apartment,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sélection de la priorité
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Priorité',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: _priorites.map((priorite) {
                            bool isSelected = _selectedPriorite == priorite['value'];
                            return ChoiceChip(
                              label: Text(priorite['label']),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedPriorite = priorite['value'];
                                  });
                                }
                              },
                              backgroundColor: Colors.grey[100],
                              selectedColor: (priorite['color'] as Color).withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: isSelected ? priorite['color'] : Colors.grey[700],
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sélection de l'agent
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Agent de service',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _agents.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text('Aucun agent disponible'),
                                ),
                              )
                            : Column(
                                children: _agents.map((agent) {
                                  bool isSelected = _selectedAgent?.id == agent.id;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedAgent = agent;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? _bleuMoyen.withOpacity(0.1)
                                            : Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? _bleuMoyen
                                              : Colors.grey[200]!,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: _bleuMoyen.withOpacity(0.1),
                                            child: Text(
                                              agent.nom[0].toUpperCase(),
                                              style: TextStyle(
                                                color: _bleuMoyen,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  agent.nom,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  agent.email,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle,
                                              color: _vertMoyen,
                                              size: 20,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey[400]!),
                          ),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isTransferring ? null : _transferer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _vertMoyen,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isTransferring
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Transférer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _bleuMoyen),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}