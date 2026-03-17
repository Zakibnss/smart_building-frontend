import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class ParkingManagementScreen extends StatefulWidget {
  @override
  _ParkingManagementScreenState createState() => _ParkingManagementScreenState();
}

class _ParkingManagementScreenState extends State<ParkingManagementScreen> {
  int _selectedTab = 0; // 0: Configuration, 1: Attribution, 2: Historique
  
  List<dynamic> _places = [];
  List<dynamic> _residentsSansParking = [];
  List<dynamic> _history = [];
  Map<String, dynamic> _stats = {};
  
  bool _isLoading = true;
  
  // Contrôleurs pour la configuration
  final TextEditingController _residentController = TextEditingController();
  final TextEditingController _visiteurController = TextEditingController();

  final Color _bleuFonce = const Color(0xFF0D1F3C);
  final Color _bleuMoyen = const Color(0xFF1A3A6B);
  final Color _vertMoyen = const Color(0xFF4CAF50);
  final Color _orange = const Color(0xFFFF9800);
  final Color _rouge = const Color(0xFFF44336);
  final Color _violet = const Color(0xFF9C27B0);
  final Color _bleuClair = const Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Charger les places et résidents
      final response = await ApiService.getParkingConfig();
      if (response['success'] == true) {
        setState(() {
          _places = response['places'] ?? [];
          _residentsSansParking = response['residents_sans_parking'] ?? [];
        });
      }

      // Charger les statistiques
      final statsResponse = await ApiService.getParkingStats();
      if (statsResponse['success'] == true) {
        setState(() {
          _stats = statsResponse['stats'] ?? {};
        });
      }

      // Charger l'historique
      final historyResponse = await ApiService.getParkingHistory();
      if (historyResponse['success'] == true) {
        setState(() {
          _history = historyResponse['history'] ?? [];
        });
      }

    } catch (e) {
      print('❌ Erreur chargement: $e');
      _showSnackBar('Erreur de chargement: $e', _rouge);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _configureParking() async {
    if (_residentController.text.isEmpty || _visiteurController.text.isEmpty) {
      _showSnackBar('Veuillez remplir tous les champs', _orange);
      return;
    }

    final placesResident = int.tryParse(_residentController.text) ?? 0;
    final placesVisiteur = int.tryParse(_visiteurController.text) ?? 0;

    if (placesResident <= 0 || placesVisiteur <= 0) {
      _showSnackBar('Les nombres doivent être positifs', _orange);
      return;
    }

    try {
      final response = await ApiService.configureParking(
        placesResident,
        placesVisiteur,
      );

      if (response['success'] == true) {
        _showSnackBar('Parking configuré avec succès!', _vertMoyen);
        _residentController.clear();
        _visiteurController.clear();
        _loadData();
      } else {
        _showSnackBar(response['message'] ?? 'Erreur', _rouge);
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', _rouge);
    }
  }

  Future<void> _assignerPlace(int residentId, int parkingId) async {
    try {
      final response = await ApiService.assignParkingPlace(residentId, parkingId);

      if (response['success'] == true) {
        _showSnackBar('Place assignée avec succès!', _vertMoyen);
        _loadData();
      } else {
        _showSnackBar(response['message'] ?? 'Erreur', _rouge);
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', _rouge);
    }
  }

  Future<void> _libererPlace(int parkingId) async {
    try {
      final response = await ApiService.libererParkingPlaceAdmin(parkingId);

      if (response['success'] == true) {
        _showSnackBar('Place libérée!', _vertMoyen);
        _loadData();
      } else {
        _showSnackBar(response['message'] ?? 'Erreur', _rouge);
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', _rouge);
    }
  }

  void _showAssignDialog(Map<String, dynamic> resident, List<dynamic> places) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Assigner une place',
          style: TextStyle(color: _bleuFonce, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Résident: ${resident['nom'] ?? 'Inconnu'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Appartement: ${resident['numero_appartement'] ?? '?'}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const Divider(height: 24),
              const Text(
                'Places disponibles:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              places.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Aucune place disponible'),
                      ),
                    )
                  : SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: places.length,
                        itemBuilder: (context, index) {
                          final place = places[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _vertMoyen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.local_parking,
                                  color: _vertMoyen,
                                  size: 20,
                                ),
                              ),
                              title: Text(place['numero_place'] ?? 'Place ${place['id']}'),
                              subtitle: Text(place['type'] == 'resident' ? 'Résident' : 'Visiteur'),
                              onTap: () {
                                Navigator.pop(context);
                                _assignerPlace(resident['id'], place['id']);
                              },
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: _bleuMoyen),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _bleuFonce),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'GESTION PARKING',
          style: TextStyle(
            color: _bleuFonce,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Onglets
                Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      _buildTab('Configuration', 0),
                      _buildTab('Attribution', 1),
                      _buildTab('Historique', 2),
                    ],
                  ),
                ),

                Expanded(
                  child: _selectedTab == 0
                      ? _buildConfigurationTab()
                      : _selectedTab == 1
                          ? _buildAttributionTab()
                          : _buildHistoryTab(),
                ),
              ],
            ),
    );
  }

  Widget _buildTab(String title, int index) {
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
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? _bleuFonce : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfigurationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiques
          Container(
            padding: const EdgeInsets.all(16),
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
                _buildStatColumn('${_stats['total_places'] ?? 0}', 'Total'),
                _buildStatColumn('${_stats['places_occupees'] ?? 0}', 'Occupées'),
                _buildStatColumn('${_stats['places_libres'] ?? 0}', 'Libres'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Formulaire de configuration
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configurer le parking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _residentController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nombre de places résidents',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _visiteurController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nombre de places visiteurs',
                    prefixIcon: const Icon(Icons.people),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _configureParking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _vertMoyen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'APPLIQUER LA CONFIGURATION',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Résidents sans parking
          const Text(
            'Résidents sans parking',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _residentsSansParking.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Tous les résidents ont une place'),
                    ),
                  )
                : Column(
                    children: _residentsSansParking.map((resident) {
                      // Récupérer les places disponibles
                      final availablePlaces = _getAvailablePlaces();
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _bleuClair,
                            child: Text(
                              resident['nom'] != null && resident['nom'].isNotEmpty 
                                  ? resident['nom'][0].toUpperCase() 
                                  : '?',
                              style: TextStyle(color: _bleuMoyen, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            resident['nom'] ?? 'Inconnu',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('App: ${resident['numero_appartement'] ?? '?'}'),
                          
                          // Bouton d'assignation
                          trailing: availablePlaces.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Aucune place',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: () => _showAssignDialog(resident, availablePlaces),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Assigner'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _vertMoyen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    textStyle: const TextStyle(fontSize: 12),
                                  ),
                                ),
                        ),
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 20),

          // Liste des places
          const Text(
            'Places de parking',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.9,
            ),
            itemCount: _places.length,
            itemBuilder: (context, index) {
              final place = _places[index];
              return _buildPlaceCard(place);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _vertMoyen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                color: _vertMoyen,
                size: 20,
              ),
            ),
            title: Text(
              'Place ${item['numero_place'] ?? '?'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assignée à ${item['resident_nom'] ?? '?'}'),
                Text(
                  'Par ${item['assigne_par_nom'] ?? 'Admin'}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
            trailing: Text(
              _formatDate(item['date_assignation']),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place) {
    bool isOccupee = place['resident_id'] != null;
    Color color = isOccupee ? _rouge : _vertMoyen;
    String statut = isOccupee ? 'Occupée' : 'Libre';

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOccupee ? _rouge.withOpacity(0.3) : _vertMoyen.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_parking,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            place['numero_place'] ?? 'P?',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statut,
              style: TextStyle(
                fontSize: 8,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isOccupee)
            IconButton(
              icon: Icon(Icons.close, color: _rouge, size: 16),
              onPressed: () => _libererPlace(place['id']),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAvailablePlaces() {
    if (_places.isEmpty) return [];
    
    return _places.where((place) {
      return place != null && 
             place['resident_id'] == null && 
             place['id'] != null;
    }).map((place) => place as Map<String, dynamic>).toList();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      DateTime date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}';
    } catch (e) {
      return '';
    }
  }
}