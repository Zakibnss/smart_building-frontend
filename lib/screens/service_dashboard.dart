import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class ServiceDashboard extends StatefulWidget {
  final User user;

  const ServiceDashboard({Key? key, required this.user}) : super(key: key);

  @override
  _ServiceDashboardState createState() => _ServiceDashboardState();
}

class _ServiceDashboardState extends State<ServiceDashboard> {
  int _selectedTab = 0;
  bool _isLoading = true;
  String? _errorMessage;
  
  List<Map<String, dynamic>> _nouvellesDemandes = [];
  List<Map<String, dynamic>> _mesMissions = [];
  Map<String, dynamic> _stats = {};
  
  bool _disponible = true;

  final Color _bleuFonce = const Color(0xFF0D1F3C);
  final Color _bleuMoyen = const Color(0xFF1A3A6B);
  final Color _vertMoyen = const Color(0xFF4CAF50);
  final Color _orange = const Color(0xFFFF9800);
  final Color _rouge = const Color(0xFFF44336);
  final Color _teal = const Color(0xFF009688);
  final Color _violet = const Color(0xFF9C27B0);

  @override
  void initState() {
    super.initState();
    print('🆔 Agent ID: ${widget.user.id}');
    print('👤 Agent Nom: ${widget.user.nom}');
    print('📧 Agent Email: ${widget.user.email}');
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // 1. Charger les nouvelles demandes (en attente)
      final demandesResponse = await ApiService.getNouvellesDemandesService();
      print('📥 Demandes API - success: ${demandesResponse['success']}');
      print('📥 Demandes API - message: ${demandesResponse['message']}');
      
      if (demandesResponse['success'] == true) {
        List<Map<String, dynamic>> toutesDemandes = 
            List<Map<String, dynamic>>.from(demandesResponse['demandes'] ?? []);
        
        setState(() {
          _nouvellesDemandes = toutesDemandes
              .where((d) => d['statut'] == 'en_attente')
              .toList();
        });
        print('✅ Nouvelles demandes: ${_nouvellesDemandes.length}');
      } else {
        print('❌ Erreur demandes: ${demandesResponse['message']}');
      }

      // 2. Charger mes missions avec l'ID agent
      final agentId = widget.user.id;
      print('🆔 Appel API missions avec agent_id: $agentId');
      
      final missionsResponse = await ApiService.getMesMissionsService(agentId);
      print('📥 Missions API - success: ${missionsResponse['success']}');
      print('📥 Missions API - message: ${missionsResponse['message']}');
      
      if (missionsResponse['success'] == true) {
        setState(() {
          _mesMissions = List<Map<String, dynamic>>.from(missionsResponse['missions'] ?? []);
        });
        print('✅ Mes missions: ${_mesMissions.length}');
      } else {
        print('❌ Erreur missions: ${missionsResponse['message']}');
      }

      // 3. Charger les statistiques
      final statsResponse = await ApiService.getServiceStats(agentId);
      if (statsResponse['success'] == true) {
        setState(() {
          _stats = statsResponse['stats'] ?? {};
        });
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Erreur _loadData: $e');
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _accepterMission(Map<String, dynamic> demande) async {
    setState(() => _isLoading = true);
    
    try {
      final demandeId = demande['id'];
      final agentId = widget.user.id;
      
      print('📤 Acceptation - demande_id: $demandeId, agent_id: $agentId');
      
      final response = await ApiService.accepterMission(demandeId, agentId);
      
      print('📥 Réponse acceptation: ${response['success']} - ${response['message']}');
      
      if (response['success'] == true) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mission acceptée avec succès'),
              backgroundColor: _vertMoyen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Erreur lors de l\'acceptation'),
              backgroundColor: _rouge,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Erreur acceptation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: _rouge,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refuserMission(Map<String, dynamic> demande) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refuser la mission'),
        content: Text('Êtes-vous sûr de vouloir refuser cette mission ?\n\n${demande['type_service']} - ${demande['appartement'] ?? 'N/A'}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _rouge,
            ),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    
    try {
      final demandeId = demande['id'];
      final agentId = widget.user.id;
      
      print('📤 Refus - demande_id: $demandeId, agent_id: $agentId');
      
      final response = await ApiService.refuserMission(demandeId, agentId);
      
      if (response['success'] == true) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mission refusée'),
              backgroundColor: _orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Erreur'),
              backgroundColor: _rouge,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Erreur refus: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: _rouge,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateMissionStatut(Map<String, dynamic> mission, String nouveauStatut) async {
    setState(() => _isLoading = true);
    
    try {
      final missionId = mission['mission_id'] ?? mission['id'];
      
      print('📤 Update statut - mission_id: $missionId, nouveau_statut: $nouveauStatut');
      
      final response = await ApiService.updateMissionStatut(missionId, nouveauStatut);
      
      if (response['success'] == true) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Statut mis à jour: $nouveauStatut'),
              backgroundColor: _vertMoyen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Erreur'),
              backgroundColor: _rouge,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Erreur update statut: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: _rouge,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateDisponibilite() async {
    try {
      final response = await ApiService.updateAgentDisponibilite(widget.user.id, _disponible);
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_disponible ? 'Vous êtes maintenant disponible' : 'Vous êtes maintenant indisponible'),
              backgroundColor: _vertMoyen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Erreur mise à jour disponibilité: $e');
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _rouge,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      appBar: AppBar(
        backgroundColor: _bleuFonce,
        elevation: 0,
        title: const Text(
          'AGENT SERVICE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => _showProfileDialog(context),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () => _showNotificationsSheet(context),
              ),
              Positioned(
                right: 8,
                top: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _vertMoyen,
                    shape: BoxShape.circle,
                    border: Border.all(color: _bleuFonce, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Row(
                        children: [
                          _buildTab('Nouvelles demandes', 0, _nouvellesDemandes.length),
                          _buildTab('Mes missions', 1, _mesMissions.length),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _selectedTab == 0
                          ? _buildNouvellesDemandesList()
                          : _buildMesMissionsList(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTab(String title, int index, int count) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? _vertMoyen : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? _bleuFonce : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (count > 0 && title == 'Nouvelles demandes')
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _rouge,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
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
              onPressed: _loadData,
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

  Widget _buildNouvellesDemandesList() {
    if (_nouvellesDemandes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Aucune nouvelle demande',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Les demandes de services apparaîtront ici',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _nouvellesDemandes.length,
        itemBuilder: (context, index) {
          final demande = _nouvellesDemandes[index];
          return _buildDemandeCard(demande);
        },
      ),
    );
  }

  Widget _buildDemandeCard(Map<String, dynamic> demande) {
    Color typeColor = _getServiceColor(demande['type_service']);
    IconData typeIcon = _getServiceIcon(demande['type_service']);
    bool estUrgent = demande['priorite'] == 'urgente' || demande['est_urgent'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        demande['type_service'] ?? 'Service',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Appartement: ${demande['appartement'] ?? demande['num_appartement'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (estUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _rouge.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              demande['description'] ?? 'Aucune description',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  demande['resident_nom'] ?? 'Résident',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(demande['date_demande'] ?? demande['date_souhaitee']),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _accepterMission(demande),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Accepter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _vertMoyen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _refuserMission(demande),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Refuser'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _rouge,
                      side: BorderSide(color: _rouge),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

  Widget _buildMesMissionsList() {
    if (_mesMissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Aucune mission en cours',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Les missions que vous acceptez apparaîtront ici',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _mesMissions.length,
        itemBuilder: (context, index) {
          final mission = _mesMissions[index];
          return _buildMissionCard(mission);
        },
      ),
    );
  }

  Widget _buildMissionCard(Map<String, dynamic> mission) {
    Color typeColor = _getServiceColor(mission['type_service']);
    IconData typeIcon = _getServiceIcon(mission['type_service']);
    String statutMission = mission['statut'] ?? 'en_attente';
    Color statutColor = _getStatutColor(statutMission);
    String statutText = _getStatutText(statutMission);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission['type_service'] ?? 'Service',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Appartement: ${mission['appartement'] ?? mission['num_appartement'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statutColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statutText,
                    style: TextStyle(
                      fontSize: 10,
                      color: statutColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              mission['description'] ?? 'Aucune description',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  mission['resident_nom'] ?? 'Résident',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Icon(Icons.phone, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  mission['telephone'] ?? 'N/A',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (statutMission == 'en_cours')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _updateMissionStatut(mission, 'termine'),
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Marquer comme terminé'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _vertMoyen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            if (statutMission == 'termine')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _vertMoyen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mission['feedback'] ?? 'En attente de feedback du résident',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
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

  Color _getServiceColor(String? type) {
    switch (type) {
      case 'Plomberie':
        return _teal;
      case 'Électricité':
        return Colors.orange;
      case 'Nettoyage':
        return _vertMoyen;
      case 'Réparation':
        return _violet;
      case 'Sécurité':
        return _bleuMoyen;
      case 'Achat':
        return const Color(0xFFFFC107);
      default:
        return _bleuFonce;
    }
  }

  IconData _getServiceIcon(String? type) {
    switch (type) {
      case 'Plomberie':
        return Icons.plumbing;
      case 'Électricité':
        return Icons.electrical_services;
      case 'Nettoyage':
        return Icons.cleaning_services;
      case 'Réparation':
        return Icons.build;
      case 'Sécurité':
        return Icons.security;
      case 'Achat':
        return Icons.shopping_cart;
      default:
        return Icons.build;
    }
  }

  Color _getStatutColor(String? statut) {
    switch (statut) {
      case 'en_attente':
        return _orange;
      case 'en_cours':
        return _bleuMoyen;
      case 'termine':
        return _vertMoyen;
      default:
        return Colors.grey;
    }
  }

  String _getStatutText(String? statut) {
    switch (statut) {
      case 'en_attente':
        return 'En attente';
      case 'en_cours':
        return 'En cours';
      case 'termine':
        return 'Terminé';
      default:
        return statut ?? 'Inconnu';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Date non spécifiée';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Mon profil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: _bleuFonce,
                child: Text(
                  widget.user.nom.isNotEmpty ? widget.user.nom[0].toUpperCase() : 'A',
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              _infoRow(Icons.person, 'Nom', widget.user.nom),
              const Divider(),
              _infoRow(Icons.email, 'Email', widget.user.email),
              const Divider(),
              _infoRow(Icons.build, 'Rôle', 'Agent Service'),
              const Divider(),
              Row(
                children: [
                  Icon(Icons.toggle_on, color: _vertMoyen),
                  const SizedBox(width: 8),
                  const Text('Disponibilité: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Switch(
                    value: _disponible,
                    onChanged: (value) async {
                      setStateDialog(() => _disponible = value);
                      setState(() => _disponible = value);
                      await _updateDisponibilite();
                    },
                    activeColor: _vertMoyen,
                  ),
                  Text(
                    _disponible ? 'Disponible' : 'Indisponible',
                    style: TextStyle(color: _disponible ? _vertMoyen : _rouge),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _bleuMoyen),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder(
                future: ApiService.getNotificationsAgent(widget.user.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasData && snapshot.data!['success'] == true) {
                    final notifications = snapshot.data!['notifications'] as List? ?? [];
                    
                    if (notifications.isEmpty) {
                      return const Center(
                        child: Text('Aucune notification'),
                      );
                    }
                    
                    return ListView.separated(
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final n = notifications[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: _bleuMoyen.withOpacity(0.15),
                            child: Icon(Icons.notifications, color: _bleuMoyen, size: 18),
                          ),
                          title: Text(
                            n['titre'] ?? 'Notification',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            n['contenu'] ?? '',
                            style: const TextStyle(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            _formatDate(n['date_creation']),
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                          onTap: () async {
                            if (n['est_lu'] == false) {
                              await ApiService.marquerNotificationLueAgent(n['id']);
                              setState(() {});
                            }
                          },
                        );
                      },
                    );
                  }
                  
                  return const Center(
                    child: Text('Erreur de chargement des notifications'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}