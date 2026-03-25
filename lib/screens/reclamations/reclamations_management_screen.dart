import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/reclamation.dart';

class ReclamationsManagementScreen extends StatefulWidget {
  const ReclamationsManagementScreen({Key? key}) : super(key: key);

  @override
  _ReclamationsManagementScreenState createState() => _ReclamationsManagementScreenState();
}

class _ReclamationsManagementScreenState extends State<ReclamationsManagementScreen> with TickerProviderStateMixin {
  int _selectedTab = 0; // 0: Toutes, 1: En attente, 2: En cours, 3: Résolues
  
  List<Reclamation> _reclamations = [];
  List<Reclamation> _filteredReclamations = [];
  List<Map<String, dynamic>> _agents = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  
  // Statistiques
  int _totalReclamations = 0;
  int _enAttente = 0;
  int _enCours = 0;
  int _resolues = 0;
  
  // Animation
  late AnimationController _refreshController;
  
  // Couleurs
  final Color _bleuFonce = const Color(0xFF0D1F3C);
  final Color _bleuMoyen = const Color(0xFF1A3A6B);
  final Color _vertMoyen = const Color(0xFF4CAF50);
  final Color _orange = const Color(0xFFFF9800);
  final Color _rouge = const Color(0xFFF44336);
  final Color _violet = const Color(0xFF9C27B0);

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadReclamations();
    _loadAgents();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadReclamations() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getReclamations();
      
      if (response['success'] == true) {
        List<Reclamation> reclamations = [];
        if (response['reclamations'] != null) {
          for (var item in response['reclamations']) {
            try {
              reclamations.add(Reclamation.fromJson(item));
            } catch (e) {
              print('❌ Erreur parsing item: $e');
              print('❌ Item: $item');
            }
          }
        }
        
        setState(() {
          _reclamations = reclamations;
          _applyFilters();
          _calculerStatistiques();
          _isLoading = false;
        });
        
        print('✅ ${reclamations.length} réclamations chargées');
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Erreur de chargement';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur catch: $e');
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadAgents() async {
    try {
      final agents = await ApiService.getServiceAgents();
      setState(() {
        _agents = agents.map((agent) => {
          'id': agent.id,
          'nom': agent.nom,
        }).toList();
      });
    } catch (e) {
      print('❌ Erreur chargement agents: $e');
    }
  }

  void _calculerStatistiques() {
    _totalReclamations = _reclamations.length;
    _enAttente = _reclamations.where((r) => r.statut.toLowerCase().contains('attente')).length;
    _enCours = _reclamations.where((r) => r.statut.toLowerCase().contains('cours')).length;
    _resolues = _reclamations.where((r) => 
      r.statut.toLowerCase().contains('resolue') || 
      r.statut.toLowerCase().contains('résolue')
    ).length;
  }

  void _applyFilters() {
    _filteredReclamations = _reclamations.where((reclamation) {
      // Filtre par recherche
      bool matchesSearch = _searchQuery.isEmpty ||
          reclamation.titre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          reclamation.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (reclamation.residentNom?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (reclamation.appartement?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      // Filtre par statut selon l'onglet sélectionné
      bool matchesStatus = true;
      switch (_selectedTab) {
        case 0: // Toutes
          matchesStatus = true;
          break;
        case 1: // En attente
          matchesStatus = reclamation.statut.toLowerCase().contains('attente');
          break;
        case 2: // En cours
          matchesStatus = reclamation.statut.toLowerCase().contains('cours');
          break;
        case 3: // Résolues
          matchesStatus = reclamation.statut.toLowerCase().contains('resolue') || 
                          reclamation.statut.toLowerCase().contains('résolue');
          break;
      }
      
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _updateSearch(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  Future<void> _updateReclamationStatus(int reclamationId, String newStatus) async {
    try {
      final response = await ApiService.updateReclamationStatus(reclamationId, newStatus);
      
      if (response['success'] == true) {
        await _loadReclamations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Statut mis à jour avec succès'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Erreur'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _assignerReclamation(int reclamationId, int agentId) async {
    try {
      final response = await ApiService.assignerReclamation(reclamationId, agentId);
      
      if (response['success'] == true) {
        await _loadReclamations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Réclamation assignée avec succès'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Erreur'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getStatusText(String statut) {
    switch (statut.toLowerCase()) {
      case 'en_attente':
        return 'En attente';
      case 'en_cours':
        return 'En cours';
      case 'resolue':
      case 'résolue':
        return 'Résolue';
      default:
        return statut;
    }
  }

  Color _getStatusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'en_attente':
        return Colors.orange;
      case 'en_cours':
        return _bleuMoyen;
      case 'resolue':
      case 'résolue':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String statut) {
    switch (statut.toLowerCase()) {
      case 'en_attente':
        return Icons.access_time;
      case 'en_cours':
        return Icons.autorenew;
      case 'resolue':
      case 'résolue':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Gestion des Réclamations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _bleuFonce,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Barre de recherche
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: _updateSearch,
                    decoration: InputDecoration(
                      hintText: 'Rechercher une réclamation...',
                      prefixIcon: Icon(Icons.search, color: _bleuMoyen),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              
              // Statistiques
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildStatChip('Total', _totalReclamations.toString(), _bleuMoyen),
                    const SizedBox(width: 8),
                    _buildStatChip('En attente', _enAttente.toString(), Colors.orange),
                    const SizedBox(width: 8),
                    _buildStatChip('En cours', _enCours.toString(), _bleuFonce),
                    const SizedBox(width: 8),
                    _buildStatChip('Résolues', _resolues.toString(), Colors.green),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReclamations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _filteredReclamations.isEmpty
                  ? _buildEmptyState()
                  : _buildReclamationsList(),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadReclamations,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _bleuFonce,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Aucune réclamation'
                  : 'Aucune réclamation trouvée pour "$_searchQuery"',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReclamationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _filteredReclamations.length,
      itemBuilder: (context, index) {
        final reclamation = _filteredReclamations[index];
        return _buildReclamationCard(reclamation);
      },
    );
  }

  Widget _buildReclamationCard(Reclamation reclamation) {
    final statusColor = _getStatusColor(reclamation.statut);
    final statusText = _getStatusText(reclamation.statut);
    final statusIcon = _getStatusIcon(reclamation.statut);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showReclamationDetails(reclamation),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec statut
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reclamation.titre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                reclamation.residentNom ?? 'Inconnu',
                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                reclamation.description,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Informations supplémentaires
              Row(
                children: [
                  Icon(Icons.apartment, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'App: ${reclamation.appartement ?? '?'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.category, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    reclamation.categorie ?? 'Général',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(reclamation.dateCreation),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              
              // Agent assigné (si existant)
              if (reclamation.assigneANom != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _bleuMoyen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline, size: 14, color: _bleuMoyen),
                      const SizedBox(width: 4),
                      Text(
                        'Assigné à: ${reclamation.assigneANom}',
                        style: TextStyle(
                          fontSize: 11,
                          color: _bleuMoyen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showReclamationDetails(Reclamation reclamation) {
    final statusColor = _getStatusColor(reclamation.statut);
    final statusText = _getStatusText(reclamation.statut);
    final statusIcon = _getStatusIcon(reclamation.statut);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // En-tête
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(statusIcon, color: statusColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Réclamation #${reclamation.id}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon, color: statusColor, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 32),
                  
                  // Informations
                  _buildDetailSection(
                    'Titre',
                    reclamation.titre,
                    Icons.title,
                  ),
                  
                  _buildDetailSection(
                    'Description',
                    reclamation.description,
                    Icons.description,
                  ),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailSection(
                          'Résident',
                          reclamation.residentNom ?? 'Inconnu',
                          Icons.person,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailSection(
                          'Appartement',
                          reclamation.appartement ?? '?',
                          Icons.apartment,
                        ),
                      ),
                    ],
                  ),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailSection(
                          'Catégorie',
                          reclamation.categorie ?? 'Général',
                          Icons.category,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailSection(
                          'Lieu',
                          reclamation.lieu ?? 'Complexe',
                          Icons.location_on,
                        ),
                      ),
                    ],
                  ),
                  
                  _buildDetailSection(
                    'Date',
                    _formatDate(reclamation.dateCreation),
                    Icons.calendar_today,
                  ),
                  
                  if (reclamation.dateResolution != null)
                    _buildDetailSection(
                      'Date résolution',
                      _formatDate(reclamation.dateResolution!),
                      Icons.check_circle,
                    ),
                  
                  if (reclamation.assigneANom != null)
                    _buildDetailSection(
                      'Assigné à',
                      reclamation.assigneANom!,
                      Icons.person_outline,
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Actions
                  const Text(
                    'Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Changement de statut
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildActionChip(
                        'En attente',
                        Colors.orange,
                        () => _updateReclamationStatus(reclamation.id, 'en_attente'),
                        isSelected: reclamation.statut.toLowerCase().contains('attente'),
                      ),
                      _buildActionChip(
                        'En cours',
                        _bleuMoyen,
                        () => _updateReclamationStatus(reclamation.id, 'en_cours'),
                        isSelected: reclamation.statut.toLowerCase().contains('cours'),
                      ),
                      _buildActionChip(
                        'Résolue',
                        Colors.green,
                        () => _updateReclamationStatus(reclamation.id, 'resolue'),
                        isSelected: reclamation.statut.toLowerCase().contains('resolue') ||
                                    reclamation.statut.toLowerCase().contains('résolue'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Assignation
                  if (_agents.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assigner à un agent',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _agents.map((agent) {
                            return FilterChip(
                              label: Text(agent['nom']),
                              selected: reclamation.assigneAId == agent['id'],
                              onSelected: (selected) {
                                if (selected) {
                                  _assignerReclamation(reclamation.id, agent['id']);
                                  Navigator.pop(context); // Close bottom sheet after assignment
                                }
                              },
                              backgroundColor: Colors.grey[100],
                              selectedColor: _bleuMoyen.withOpacity(0.2),
                              checkmarkColor: _bleuMoyen,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Feedback si résolu
                  if (reclamation.statut.toLowerCase().contains('resolue') ||
                      reclamation.statut.toLowerCase().contains('résolue')) ...[
                    const Text(
                      'Feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              reclamation.feedback ?? 'Aucun feedback',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('FERMER'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _bleuMoyen),
          const SizedBox(width: 8),
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

  Widget _buildActionChip(String label, Color color, VoidCallback onTap, {bool isSelected = false}) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[100],
      selectedColor: color.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      avatar: isSelected ? Icon(Icons.check, color: color, size: 16) : null,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}