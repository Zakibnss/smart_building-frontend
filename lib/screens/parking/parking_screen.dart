import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';

class ParkingScreen extends StatefulWidget {
  final User user;

  const ParkingScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ParkingScreenState createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  bool _isLoading = true;
  bool _hasPlace = false;
  Map<String, dynamic>? _myPlace;
  List<dynamic> _availablePlaces = [];
  Map<String, dynamic> _stats = {};

  final Color _bleuFonce = const Color(0xFF0D1F3C);
  final Color _bleuMoyen = const Color(0xFF1A3A6B);
  final Color _vertMoyen = const Color(0xFF4CAF50);
  final Color _orange = const Color(0xFFFF9800);
  final Color _rouge = const Color(0xFFF44336);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Charger la place du résident
      final myPlaceResponse = await ApiService.getParkingInfo(widget.user.id);
      
      // Charger les places disponibles
      final availableResponse = await ApiService.getAvailableParkingPlaces();

      // Charger les statistiques
      final statsResponse = await ApiService.getParkingStats();

      setState(() {
        if (myPlaceResponse['success'] && myPlaceResponse['has_place']) {
          _hasPlace = true;
          _myPlace = myPlaceResponse['place'];
        } else {
          _hasPlace = false;
        }

        if (availableResponse['success']) {
          _availablePlaces = availableResponse['places'] ?? [];
        }

        if (statsResponse['success']) {
          _stats = statsResponse['stats'] ?? {};
        }

        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur chargement parking: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reservePlace(int parkingId) async {
    try {
      final response = await ApiService.reserveParkingPlace(widget.user.id, parkingId);
      
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Place réservée avec succès!'),
            backgroundColor: _vertMoyen,
          ),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Erreur lors de la réservation'),
            backgroundColor: _rouge,
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur réservation: $e');
    }
  }

  Future<void> _libererPlace() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Libérer la place'),
        content: const Text('Êtes-vous sûr de vouloir libérer votre place de parking ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final response = await ApiService.libererParkingPlace(widget.user.id);
                
                if (response['success']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Place libérée avec succès!'),
                      backgroundColor: _vertMoyen,
                    ),
                  );
                  _loadData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['message'] ?? 'Erreur'),
                      backgroundColor: _rouge,
                    ),
                  );
                }
              } catch (e) {
                print('❌ Erreur libération: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _rouge,
            ),
            child: const Text('Libérer'),
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
          'PARKING',
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
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistiques
                   

                    const SizedBox(height: 20),

                    // Ma place (si existante)
                    if (_hasPlace && _myPlace != null) ...[
                      const Text(
                        '🗳️ MA PLACE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
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
                          border: Border(
                            left: BorderSide(color: _vertMoyen, width: 4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _vertMoyen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.local_parking,
                                color: _vertMoyen,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _myPlace!['numero'],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: _bleuFonce,
                                    ),
                                  ),
                                  const Text(
                                    'Votre place actuelle',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _libererPlace,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _rouge,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Libérer'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Places disponibles
                    if (!_hasPlace) ...[
                      const Text(
                        '🅿️ PLACES DISPONIBLES',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_availablePlaces.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.local_parking, // CORRIGÉ: Icons.parking → Icons.local_parking
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune place disponible',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: _availablePlaces.length,
                          itemBuilder: (context, index) {
                            final place = _availablePlaces[index];
                            return _buildPlaceCard(place);
                          },
                        ),
                    ],
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

  Widget _buildPlaceCard(Map<String, dynamic> place) {
    return GestureDetector(
      onTap: () => _showReservationDialog(place),
      child: Container(
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
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _vertMoyen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_parking, // CORRIGÉ: Icons.parking → Icons.local_parking
                color: _vertMoyen,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              place['numero_place'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _bleuFonce,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _vertMoyen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Disponible',
                style: TextStyle(
                  fontSize: 10,
                  color: _vertMoyen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReservationDialog(Map<String, dynamic> place) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Icon(
          Icons.local_parking, // CORRIGÉ: Icons.parking → Icons.local_parking
          color: _vertMoyen,
          size: 50,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Réserver la place',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _bleuFonce,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Voulez-vous réserver la place ${place['numero_place']} ?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _reservePlace(place['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _vertMoyen,
            ),
            child: const Text('Réserver'),
          ),
        ],
      ),
    );
  }
}