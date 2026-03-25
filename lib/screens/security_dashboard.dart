import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SecurityDashboard extends StatefulWidget {
  final User user;

  const SecurityDashboard({Key? key, required this.user}) : super(key: key);

  @override
  _SecurityDashboardState createState() => _SecurityDashboardState();
}

class _SecurityDashboardState extends State<SecurityDashboard> with TickerProviderStateMixin {
  int _selectedBottomIndex = 0;
  bool _isLoading = true;
  bool _isMounted = true;

  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Couleurs
  final Color _bleuFonce = const Color(0xFF0D1F3C);
  final Color _bleuMoyen = const Color(0xFF1A3A6B);
  final Color _bleuCard = const Color(0xFF1E4D8C);
  final Color _vertMoyen = const Color(0xFF4CAF50);
  final Color _orange = const Color(0xFFFF9800);
  final Color _rouge = const Color(0xFFF44336);
  final Color _violet = const Color(0xFF9C27B0);

  // Données dynamiques
  List<Map<String, dynamic>> _residents = [];
  List<Map<String, dynamic>> _parkingResidents = [];
  List<Map<String, dynamic>> _parkingVisiteurs = [];
  List<Map<String, dynamic>> _colis = [];
  List<Map<String, dynamic>> _accesRecents = [];

  // Contrôleurs de recherche
  final TextEditingController _searchNomController = TextEditingController();
  final TextEditingController _searchAppartementController = TextEditingController();
  final TextEditingController _searchBatimentController = TextEditingController();
  final TextEditingController _codeRechercheController = TextEditingController();
  
  // Scanner
  MobileScannerController? _scannerController;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    
    // Animation pour pulse
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _loadData();
    _chargerAccesRecents();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    try {
      final residentsResponse = await ApiService.getTousResidents();
      if (mounted && residentsResponse['success'] == true) {
        setState(() {
          _residents = List<Map<String, dynamic>>.from(residentsResponse['residents'] ?? []);
        });
      }

      final parkingResidentsResponse = await ApiService.getParkingResidents();
      if (mounted && parkingResidentsResponse['success'] == true) {
        setState(() {
          _parkingResidents = List<Map<String, dynamic>>.from(parkingResidentsResponse['places'] ?? []);
        });
      }

      final parkingVisiteursResponse = await ApiService.getParkingVisiteurs();
      if (mounted && parkingVisiteursResponse['success'] == true) {
        setState(() {
          _parkingVisiteurs = List<Map<String, dynamic>>.from(parkingVisiteursResponse['places'] ?? []);
        });
      }

      final colisResponse = await ApiService.getDerniersColis();
      if (mounted && colisResponse['success'] == true) {
        setState(() {
          _colis = List<Map<String, dynamic>>.from(colisResponse['colis'] ?? []);
        });
      }

    } catch (e) {
      print('❌ Erreur chargement données: $e');
      if (mounted) {
        _showSnackBar('Erreur de chargement: $e', _rouge);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _chargerAccesRecents() async {
    try {
      final response = await ApiService.getAccesVisiteurEnCours();
      if (mounted && response['success'] == true) {
        setState(() {
          _accesRecents = List<Map<String, dynamic>>.from(response['acces'] ?? []);
        });
      }
    } catch (e) {
      print('❌ Erreur chargement accès récents: $e');
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _isMounted = false;
    _pulseController.dispose();
    _scannerController?.dispose();
    _searchNomController.dispose();
    _searchAppartementController.dispose();
    _searchBatimentController.dispose();
    _codeRechercheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      appBar: AppBar(
        backgroundColor: _bleuFonce,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: Text(
          'AGENT SÉCURITÉ',
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
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _getCurrentPage(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _getCurrentPage() {
    switch (_selectedBottomIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildAccueilContent();
      case 2:
        return _buildColisContent();
      case 3:
        return _buildParkingContent();
      case 4:
        return _buildHistoriqueContent();
      default:
        return _buildDashboardContent();
    }
  }

 Widget _buildBottomNav() {
  final items = [
    {'icon': Icons.dashboard, 'label': 'ACCUEIL'},
    {'icon': Icons.qr_code_scanner, 'label': 'SCANNER'},
    {'icon': Icons.inventory_2, 'label': 'COLIS'},
    {'icon': Icons.local_parking, 'label': 'PARKING'},
    {'icon': Icons.history, 'label': 'HISTORIQUE'},
  ];
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2))
      ],
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final selected = _selectedBottomIndex == i;
            return GestureDetector(
              onTap: () {
                if (mounted) {
                  setState(() {
                    _selectedBottomIndex = i;
                  });
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    items[i]['icon'] as IconData,
                    color: selected ? _bleuFonce : Colors.grey,
                    size: 22,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    items[i]['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: selected ? _bleuFonce : Colors.grey,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    ),
  );
}

  // ── PAGE ACCUEIL AVEC SCANNER ─────────────────────────────
  Widget _buildAccueilContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _buildAgentCard(),
          const SizedBox(height: 20),
          _buildQRScannerCard(),
          const SizedBox(height: 20),
          _buildRechercheCodeCard(),
          const SizedBox(height: 20),
          _buildAccesRecentsCard(),
        ],
      ),
    );
  }

  Widget _buildQRScannerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_bleuMoyen, _violet],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Scanner QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.qr_code_scanner, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _showQRScanner,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: double.infinity,
                        height: 4,
                        margin: EdgeInsets.only(
                          top: 100 * _pulseAnimation.value,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Icon(
                    Icons.qr_code_scanner,
                    size: 80,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  Positioned(
                    bottom: 20,
                    child: Text(
                      'Touchez pour scanner',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScannerActionButton(
                icon: Icons.flash_on,
                label: 'Flash',
                onTap: () => _scannerController?.toggleTorch(),
              ),
              _buildScannerActionButton(
                icon: Icons.cameraswitch,
                label: 'Caméra',
                onTap: () => _scannerController?.switchCamera(),
              ),
              _buildScannerActionButton(
                icon: Icons.history,
                label: 'Historique',
                onTap: () => setState(() => _selectedBottomIndex = 4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScannerActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildRechercheCodeCard() {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔍 Recherche par code',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeRechercheController,
                  decoration: InputDecoration(
                    hintText: 'Entrez le code à 6 chiffres',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.qr_code, color: _bleuMoyen),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_bleuMoyen, _violet],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: () => _rechercherParCode(_codeRechercheController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  child: const Text(
                    'Vérifier',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccesRecentsCard() {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📋 Accès récents',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _selectedBottomIndex = 4),
                child: Text(
                  'Voir tout',
                  style: TextStyle(color: _vertMoyen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _accesRecents.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Aucun accès récent'),
                  ),
                )
              : Column(
                  children: _accesRecents.take(3).map((acces) {
                    return _buildAccesRecentTile(acces);
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildAccesRecentTile(Map<String, dynamic> acces) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: acces['statut'] == 'actif' 
                  ? _vertMoyen.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              acces['statut'] == 'actif' 
                  ? Icons.check_circle 
                  : Icons.history,
              color: acces['statut'] == 'actif' ? _vertMoyen : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  acces['nom_visiteur'] ?? 'Visiteur',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'App: ${acces['appartement'] ?? '?'} • Code: ${acces['code_acces']}',
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
              color: acces['statut'] == 'actif'
                  ? _vertMoyen.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              acces['statut'] == 'actif' ? 'Actif' : 'Expiré',
              style: TextStyle(
                fontSize: 10,
                color: acces['statut'] == 'actif' ? _vertMoyen : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SCANNER QR CODE ───────────────────────────────────────
 void _showQRScanner() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scanner QR Code',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: MobileScanner(
              controller: _scannerController ??= MobileScannerController(
                formats: [BarcodeFormat.qrCode],
                detectionSpeed: DetectionSpeed.normal,
              ),
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
                    _scannerController?.stop();
                    Navigator.pop(context);
                    _verifierCodeAcces(barcode.rawValue!);
                    break;
                  }
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScannerControl(
                  icon: Icons.flash_on,
                  label: 'Flash',
                  onTap: () => _scannerController?.toggleTorch(),
                ),
                _buildScannerControl(
                  icon: Icons.cameraswitch,
                  label: 'Caméra',
                  onTap: () => _scannerController?.switchCamera(),
                ),
                _buildScannerControl(
                  icon: Icons.close,
                  label: 'Fermer',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildScannerControl({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _bleuMoyen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _bleuMoyen),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifierCodeAcces(String code) async {
  if (await Vibration.hasVibrator() ?? false) {
    Vibration.vibrate(duration: 100);
  }
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
    // Appel API réel
    final response = await ApiService.verifierCodeAcces(code);
    
    if (!mounted) return;
    Navigator.pop(context);

    if (response['success'] == true && response['valide'] == true) {
      // Accès autorisé
      _showAccesAutoriseDialog(response['visiteur']);
    } else {
      // Accès refusé
      _showAccesRefuseDialog(response['message'] ?? 'Code invalide');
    }
  } catch (e) {
    if (!mounted) return;
    Navigator.pop(context);
    _showSnackBar('Erreur: $e', _rouge);
  }
}

  Future<void> _rechercherParCode(String code) async {
    if (code.length != 6) {
      _showSnackBar('Le code doit comporter 6 chiffres', _orange);
      return;
    }
    await _verifierCodeAcces(code);
  }

 void _showAccesAutoriseDialog(Map<String, dynamic> visiteur) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 40),
      ),
      titlePadding: const EdgeInsets.only(top: 30),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '✅ ACCÈS AUTORISÉ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildResultInfoRow(Icons.person, 'Visiteur', visiteur['nom_visiteur'] ?? 'Inconnu'),
                const Divider(height: 16),
                _buildResultInfoRow(Icons.apartment, 'Appartement', visiteur['appartement'] ?? '?'),
                const Divider(height: 16),
                _buildResultInfoRow(Icons.access_time, 'Heure', '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}'),
                const Divider(height: 16),
                _buildResultInfoRow(Icons.qr_code, 'Code', visiteur['code_acces'] ?? ''),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('FERMER'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _marquerAccesUtilise(visiteur['id']);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _vertMoyen,
          ),
          child: const Text('Marquer comme utilisé'),
        ),
      ],
    ),
  ).then((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.celebration, color: Colors.white),
            SizedBox(width: 8),
            Text('Bienvenue ! Accès autorisé'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  });
}
void _showAccesExpireDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _orange,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.warning, color: Colors.white, size: 40),
      ),
      titlePadding: const EdgeInsets.only(top: 30),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '⚠️ ACCÈS EXPIRÉ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          const Text(
            'Veuillez contacter le résident pour un nouveau code d\'accès.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('FERMER'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _showQRScanner();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _bleuMoyen,
          ),
          child: const Text('Scanner à nouveau'),
        ),
      ],
    ),
  );
}
  void _showAccesRefuseDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _rouge,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 40),
        ),
        titlePadding: const EdgeInsets.only(top: 30),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '❌ ACCÈS REFUSÉ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('FERMER'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showQRScanner();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _bleuMoyen,
            ),
            child: const Text('Scanner à nouveau'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _bleuMoyen),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _marquerAccesUtilise(int accesId) async {
  try {
    final response = await ApiService.terminerAccesVisiteur(accesId);
    
    if (!mounted) return;
    
    if (response['success'] == true) {
      _showSnackBar('Accès marqué comme utilisé', _vertMoyen);
      _chargerAccesRecents(); // Recharger la liste
    } else {
      _showSnackBar(response['message'] ?? 'Erreur', _rouge);
    }
  } catch (e) {
    _showSnackBar('Erreur: $e', _rouge);
  }
}

  // ── PAGE HISTORIQUE ───────────────────────────────────────
  Widget _buildHistoriqueContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 Historique des accès',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1F3C),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_bleuMoyen, _violet],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChiffre('Total', '${_accesRecents.length}'),
                _buildStatChiffre('Actifs', '${_accesRecents.where((a) => a['statut'] == 'actif').length}'),
                _buildStatChiffre('Expirés', '${_accesRecents.where((a) => a['statut'] != 'actif').length}'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _accesRecents.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text('Aucun historique d\'accès'),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _accesRecents.length,
                  itemBuilder: (context, index) {
                    return _buildHistoriqueTile(_accesRecents[index]);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildStatChiffre(String label, String valeur) {
    return Column(
      children: [
        Text(
          valeur,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
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

  Widget _buildHistoriqueTile(Map<String, dynamic> acces) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: acces['statut'] == 'actif'
              ? _vertMoyen.withOpacity(0.2)
              : Colors.orange.withOpacity(0.2),
          child: Icon(
            acces['statut'] == 'actif' ? Icons.check : Icons.access_time,
            color: acces['statut'] == 'actif' ? _vertMoyen : Colors.orange,
          ),
        ),
        title: Text(acces['nom_visiteur'] ?? 'Visiteur'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App: ${acces['appartement'] ?? '?'}'),
            Text('Code: ${acces['code_acces']}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: acces['statut'] == 'actif'
                    ? _vertMoyen.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                acces['statut'] == 'actif' ? 'Actif' : 'Expiré',
                style: TextStyle(
                  fontSize: 11,
                  color: acces['statut'] == 'actif' ? _vertMoyen : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(acces['date_arrivee']),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => _showDetailsAcces(acces),
      ),
    );
  }

  void _showDetailsAcces(Map<String, dynamic> acces) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 16),
            const Text(
              'Détails de l\'accès',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _buildDetailRow('Visiteur', acces['nom_visiteur'] ?? 'N/A'),
            _buildDetailRow('CIN', acces['cin'] ?? 'N/A'),
            _buildDetailRow('Appartement', acces['appartement'] ?? 'N/A'),
            _buildDetailRow('Code', acces['code_acces']?.toString() ?? 'N/A'),
            _buildDetailRow('Durée', acces['duree'] ?? 'N/A'),
            _buildDetailRow('Date', _formatDate(acces['date_arrivee'])),
            _buildDetailRow('Statut', acces['statut'] ?? 'N/A'),
            const SizedBox(height: 16),
            if (acces['statut'] == 'actif')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _marquerAccesUtilise(acces['id']);
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Marquer comme utilisé'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _vertMoyen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ── PAGE DASHBOARD (ACCUEIL) ─────────────────────────────────
  Widget _buildDashboardContent() {
    print('🔄 _buildDashboardContent - _colis: ${_colis.length}');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _buildAgentCard(),
          const SizedBox(height: 14),
          
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.inventory_2,
                  title: 'Enregistrer\nColis',
                  onTap: () => _showEnregistrerColisDialog(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.directions_car,
                  title: 'Contrôle\nParking',
                  onTap: () => _showControleParkingDialog(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.badge,
                  title: 'Vérifier\nRésident',
                  onTap: () => _showVerifierResidentDialog(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.vpn_key,
                  title: 'Accès\nVisiteur',
                  onTap: () => _showAccesVisiteurDialog(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildSection(
            title: 'Derniers colis enregistrés',
            child: _colis.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Aucun colis enregistré'),
                    ),
                  )
                : Column(
                    children: _colis.take(5).map((colis) => _buildColisRow(colis)).toList(),
                  ),
          ),
          const SizedBox(height: 14),
          
          _buildSection(
            title: 'État du parking',
            child: Column(
              children: [
                _buildParkingStats(),
                const SizedBox(height: 10),
                const Text(
                  'Places résidents:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                _parkingResidents.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Aucune place résident'),
                      )
                    : Column(
                        children: _parkingResidents.take(3).map((p) => _buildParkingResidentRow(p)).toList(),
                      ),
                const SizedBox(height: 8),
                const Text(
                  'Places visiteurs:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                _parkingVisiteurs.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Aucune place visiteur'),
                      )
                    : Column(
                        children: _parkingVisiteurs.take(3).map((p) => _buildParkingVisiteurRow(p)).toList(),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('LOG OUT',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _bleuFonce,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── PAGE SERVICES ──────────────────────────────────────────
  Widget _buildServicesContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Page Services en construction',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ── PAGE COLIS ────────────────────────────────────────────
  Widget _buildColisContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestion des Colis',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D1F3C)),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showEnregistrerColisDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Nouveau colis'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _vertMoyen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tous les colis',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1F3C)),
          ),
          const SizedBox(height: 10),
          _colis.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Aucun colis'),
                  ),
                )
              : Column(
                  children: _colis.map((c) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatutColor(c['statut']).withOpacity(0.2),
                        child: Icon(
                          _getStatutIcon(c['statut']),
                          color: _getStatutColor(c['statut']),
                        ),
                      ),
                      title: Text('${c['resident_nom']} - ${c['appartement']}'),
                      subtitle: Text('${c['type_colis'] ?? c['type']} - ${c['code_retrait'] ?? c['code']}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatutColor(c['statut']).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatutText(c['statut']),
                          style: TextStyle(
                            color: _getStatutColor(c['statut']),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  )).toList(),
                ),
        ],
      ),
    );
  }

  // ── PAGE PARKING ───────────────────────────────────────────
  Widget _buildParkingContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestion du Parking',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D1F3C)),
          ),
          const SizedBox(height: 16),
          _buildParkingStats(),
          const SizedBox(height: 20),
          
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Places Résidents',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1F3C)),
                ),
                const SizedBox(height: 10),
                _parkingResidents.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Aucune place résident'),
                        ),
                      )
                    : Column(
                        children: _parkingResidents.map((p) => _buildParkingResidentRow(p)).toList(),
                      ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Places Visiteurs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1F3C)),
                ),
                const SizedBox(height: 10),
                _parkingVisiteurs.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Aucune place visiteur'),
                        ),
                      )
                    : Column(
                        children: _parkingVisiteurs.map((p) => _buildParkingVisiteurFullRow(p)).toList(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── PAGE MESSAGES ──────────────────────────────────────────
  Widget _buildMessagesContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mail_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucun message',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ── WIDGETS DE BASE ──────────────────────────────────────────────
  Widget _buildAgentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1A5276), const Color(0xFF2980B9)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.person, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agent: ${widget.user.nom}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 3),
              const Text(
                'Poste: Entrée principale',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const Text(
                'Quart: Jour (08h-16h)',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: _bleuCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _bleuFonce,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  // Fonctions utilitaires pour les statuts
  Color _getStatutColor(String? statut) {
    String s = statut?.toLowerCase() ?? '';
    if (s.contains('attente') || s == 'en_attente') {
      return Colors.orange;
    } else if (s.contains('recupere') || s.contains('récupéré') || s == 'remis') {
      return Colors.green;
    } else if (s.contains('cours') || s == 'en_cours') {
      return _bleuMoyen;
    }
    return Colors.grey;
  }

  IconData _getStatutIcon(String? statut) {
    String s = statut?.toLowerCase() ?? '';
    if (s.contains('attente') || s == 'en_attente') {
      return Icons.access_time;
    } else if (s.contains('recupere') || s.contains('récupéré') || s == 'remis') {
      return Icons.check_circle;
    } else if (s.contains('cours') || s == 'en_cours') {
      return Icons.local_shipping;
    }
    return Icons.inventory;
  }

  String _getStatutText(String? statut) {
    String s = statut?.toLowerCase() ?? '';
    if (s.contains('attente') || s == 'en_attente') {
      return 'En attente';
    } else if (s.contains('recupere') || s.contains('récupéré') || s == 'remis') {
      return 'Récupéré';
    } else if (s.contains('cours') || s == 'en_cours') {
      return 'En cours';
    }
    return statut ?? 'Inconnu';
  }

  Widget _buildColisRow(Map<String, dynamic> colis) {
    final String statut = colis['statut']?.toString().toLowerCase() ?? '';
    final bool recupere = statut.contains('recupere') || statut.contains('récupéré') || statut == 'remis';
    final String statutTexte = recupere ? 'Récupéré' : 'En attente';
    
    String residentNom = colis['resident_nom']?.toString() ?? 'Inconnu';
    String appartement = colis['appartement']?.toString() ?? '?';
    String typeColis = colis['type_colis']?.toString() ?? colis['type']?.toString() ?? 'Colis';
    String code = colis['code_retrait']?.toString() ?? colis['code']?.toString() ?? 'N/A';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            recupere ? Icons.check_circle : Icons.access_time,
            color: recupere ? _vertMoyen : Colors.orange,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$residentNom - $appartement',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$typeColis - $code',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: recupere ? _vertMoyen.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statutTexte,
              style: TextStyle(
                fontSize: 10,
                color: recupere ? _vertMoyen : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingResidentRow(Map<String, dynamic> place) {
    String statut = place['statut']?.toString().toLowerCase() ?? '';
    bool estLibre = statut.contains('libre') || statut == 'libre';
    String numero = place['numero_place']?.toString() ?? place['numero']?.toString() ?? 'Place';
    String residentNom = place['resident_nom']?.toString() ?? 'Occupé';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: estLibre ? _vertMoyen : _rouge,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            numero,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              estLibre ? 'Libre' : residentNom,
              style: TextStyle(
                fontSize: 11,
                color: estLibre ? _vertMoyen : Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingVisiteurRow(Map<String, dynamic> place) {
    String statut = place['statut']?.toString().toLowerCase() ?? '';
    bool estLibre = statut.contains('libre') || statut == 'libre';
    String numero = place['numero_place']?.toString() ?? place['numero']?.toString() ?? 'Place';
    String visiteurNom = place['visiteur_nom']?.toString() ?? '';
    String immatriculation = place['immatriculation']?.toString() ?? '';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: estLibre ? _vertMoyen : _orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            numero,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              estLibre 
                  ? 'Libre' 
                  : '$visiteurNom (${immatriculation.isEmpty ? "N/A" : immatriculation})',
              style: TextStyle(
                fontSize: 11,
                color: estLibre ? _vertMoyen : Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingVisiteurFullRow(Map<String, dynamic> place) {
    String statut = place['statut']?.toString().toLowerCase() ?? '';
    bool estLibre = statut.contains('libre') || statut == 'libre';
    String numero = place['numero_place']?.toString() ?? place['numero']?.toString() ?? 'Place';
    String visiteurNom = place['visiteur_nom']?.toString() ?? '';
    String immatriculation = place['immatriculation']?.toString() ?? '';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: estLibre ? _vertMoyen : _orange,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(numero),
        subtitle: Text(estLibre 
            ? 'Libre' 
            : '$visiteurNom - ${immatriculation.isEmpty ? "N/A" : immatriculation}'),
        trailing: estLibre
            ? ElevatedButton.icon(
                onPressed: () => _showReserverVisiteurDialog(context, place),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Réserver'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _vertMoyen,
                  foregroundColor: Colors.white,
                ),
              )
            : ElevatedButton.icon(
                onPressed: () => _libererPlaceVisiteur(place),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Libérer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildParkingStats() {
    int libresResident = _parkingResidents.where((p) {
      String statut = p['statut']?.toString().toLowerCase() ?? '';
      return statut.contains('libre') || statut == 'libre';
    }).length;
    
    int libresVisiteur = _parkingVisiteurs.where((p) {
      String statut = p['statut']?.toString().toLowerCase() ?? '';
      return statut.contains('libre') || statut == 'libre';
    }).length;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _bleuFonce.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatChip('Résidents', '${_parkingResidents.length - libresResident}/${_parkingResidents.length}', _bleuMoyen),
          _buildStatChip('Visiteurs', '${_parkingVisiteurs.length - libresVisiteur}/${_parkingVisiteurs.length}', _orange),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ── FONCTIONNALITÉ: ENREGISTRER COLIS ───────────────────────────
  Future<void> _showEnregistrerColisDialog(BuildContext context) async {
    final _typeController = TextEditingController();
    Map<String, dynamic>? residentSelectionne;
    String modeRecherche = 'nom';
    List<Map<String, dynamic>> residentsTrouves = [];

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.inventory_2, color: _bleuMoyen),
              const SizedBox(width: 8),
              const Text('Enregistrer Colis'),
            ],
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            constraints: const BoxConstraints(maxHeight: 500),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Nom'),
                          value: 'nom',
                          groupValue: modeRecherche,
                          onChanged: (value) {
                            setDlgState(() {
                              modeRecherche = value!;
                              residentSelectionne = null;
                              residentsTrouves.clear();
                              _searchNomController.clear();
                              _searchAppartementController.clear();
                              _searchBatimentController.clear();
                            });
                          },
                          activeColor: _bleuMoyen,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Appartement'),
                          value: 'appartement',
                          groupValue: modeRecherche,
                          onChanged: (value) {
                            setDlgState(() {
                              modeRecherche = value!;
                              residentSelectionne = null;
                              residentsTrouves.clear();
                              _searchNomController.clear();
                              _searchAppartementController.clear();
                              _searchBatimentController.clear();
                            });
                          },
                          activeColor: _bleuMoyen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  if (modeRecherche == 'nom') ...[
                    TextField(
                      controller: _searchNomController,
                      decoration: InputDecoration(
                        labelText: 'Nom et prénom du résident',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(Icons.search, color: _bleuMoyen),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () async {
                            final query = _searchNomController.text;
                            if (query.isEmpty) return;
                            
                            final response = await ApiService.rechercherResidentParNom(query);
                            if (mounted) {
                              setDlgState(() {
                                if (response['success'] == true && response['residents'] != null && response['residents'].isNotEmpty) {
                                  residentsTrouves = List<Map<String, dynamic>>.from(response['residents']);
                                  residentSelectionne = residentsTrouves.first;
                                } else {
                                  residentsTrouves = [];
                                  residentSelectionne = null;
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    if (residentsTrouves.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: DropdownButtonFormField<Map<String, dynamic>>(
                          decoration: InputDecoration(
                            labelText: 'Sélectionner un résident',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          value: residentSelectionne,
                          items: residentsTrouves.map((r) {
                            return DropdownMenuItem(
                              value: r,
                              child: Text('${r['nom']} - ${r['appartement']}'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDlgState(() {
                              residentSelectionne = value;
                            });
                          },
                        ),
                      ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _searchAppartementController,
                            decoration: InputDecoration(
                              labelText: 'Numéro',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _searchBatimentController,
                            decoration: InputDecoration(
                              labelText: 'Bâtiment',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search, color: _bleuMoyen),
                          onPressed: () async {
                            final apt = _searchAppartementController.text;
                            final bat = _searchBatimentController.text;
                            
                            final response = await ApiService.rechercherResidentParAppartement(apt, bat);
                            if (mounted) {
                              setDlgState(() {
                                if (response['success'] == true && response['residents'] != null && response['residents'].isNotEmpty) {
                                  residentsTrouves = List<Map<String, dynamic>>.from(response['residents']);
                                  residentSelectionne = residentsTrouves.first;
                                } else {
                                  residentsTrouves = [];
                                  residentSelectionne = null;
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    if (residentsTrouves.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: DropdownButtonFormField<Map<String, dynamic>>(
                          decoration: InputDecoration(
                            labelText: 'Sélectionner un résident',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          value: residentSelectionne,
                          items: residentsTrouves.map((r) {
                            return DropdownMenuItem(
                              value: r,
                              child: Text('${r['nom']} - ${r['appartement']}'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDlgState(() {
                              residentSelectionne = value;
                            });
                          },
                        ),
                      ),
                  ],

                  const SizedBox(height: 12),

                  if (residentSelectionne != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _vertMoyen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _vertMoyen.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Résident trouvé:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Nom: ${residentSelectionne!['nom']}'),
                          Text('Appartement: ${residentSelectionne!['appartement']}'),
                          Text('Bâtiment: ${residentSelectionne!['batiment']}'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: _typeController,
                      decoration: InputDecoration(
                        labelText: 'Type de colis',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(Icons.inventory, color: _bleuMoyen),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: residentSelectionne == null
                  ? null
                  : () async {
                      if (_typeController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Veuillez saisir le type de colis'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      final colisData = {
                        'resident_id': residentSelectionne!['id'],
                        'type_colis': _typeController.text,
                        'agent_securite_id': widget.user.id,
                      };

                      final response = await ApiService.enregistrerColis(colisData);
                      
                      if (!mounted) return;
                      
                      Navigator.pop(context);

                      if (response['success'] == true) {
                        _loadData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Colis enregistré avec succès ✓ Code: ${response['code']}'),
                            backgroundColor: _vertMoyen,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response['message'] ?? 'Erreur'),
                            backgroundColor: _rouge,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: residentSelectionne == null ? Colors.grey : _bleuMoyen,
              ),
              child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── CONTRÔLE PARKING ────────────────────────────────────────────
  void _showControleParkingDialog(BuildContext context) {
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Contrôle Parking',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 16),

              // Places Résidents
              const Text('Places Résidents',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 150,
                child: _parkingResidents.isEmpty
                    ? const Center(child: Text('Aucune place'))
                    : ListView.builder(
                        itemCount: _parkingResidents.length,
                        itemBuilder: (context, i) {
                          final p = _parkingResidents[i];
                          String statut = p['statut']?.toString().toLowerCase() ?? '';
                          final estLibre = statut.contains('libre') || statut == 'libre';
                          
                          return ListTile(
                            dense: true,
                            leading: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: estLibre ? _vertMoyen : _rouge,
                                shape: BoxShape.circle,
                              ),
                            ),
                            title: Text(p['numero_place'] ?? p['numero'] ?? 'Place'),
                            subtitle: Text(estLibre 
                                ? 'Libre' 
                                : p['resident_nom'] ?? 'Occupé'),
                            trailing: ElevatedButton(
                              onPressed: estLibre ? null : () {
                                // Logique pour vérifier la place
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: estLibre ? Colors.grey : _rouge,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: Text(
                                'Vérifier',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const Divider(height: 20),

              // Places Visiteurs
              const Text('Places Visiteurs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: _parkingVisiteurs.isEmpty
                    ? const Center(child: Text('Aucune place'))
                    : ListView.builder(
                        itemCount: _parkingVisiteurs.length,
                        itemBuilder: (context, i) {
                          final p = _parkingVisiteurs[i];
                          String statut = p['statut']?.toString().toLowerCase() ?? '';
                          final estLibre = statut.contains('libre') || statut == 'libre';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 6),
                            child: ListTile(
                              leading: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: estLibre ? _vertMoyen : _orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              title: Text(p['numero_place'] ?? p['numero'] ?? 'Place'),
                              subtitle: Text(estLibre 
                                  ? 'Libre' 
                                  : '${p['visiteur_nom']} - ${p['immatriculation']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (estLibre)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _showReserverVisiteurDialog(context, p);
                                      },
                                      icon: const Icon(Icons.add, size: 14),
                                      label: const Text('Réserver'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _vertMoyen,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                      ),
                                    )
                                  else
                                    ElevatedButton.icon(
                                      onPressed: () => _libererPlaceVisiteur(p),
                                      icon: const Icon(Icons.close, size: 14),
                                      label: const Text('Libérer'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _orange,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Future<void> _showReserverVisiteurDialog(BuildContext context, Map<String, dynamic> place) async {
  final _nomController = TextEditingController();
  final _immatriculationController = TextEditingController();
  bool _isLoading = false;

  if (!mounted) return;

  showDialog(
    context: context,
    barrierDismissible: !_isLoading,
    builder: (context) => StatefulBuilder(
      builder: (ctx, setModalState) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.local_parking, color: _vertMoyen),
            const SizedBox(width: 8),
            Text('Réserver ${place['numero_place'] ?? place['numero']}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nomController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Nom du visiteur',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.person, color: _vertMoyen),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _immatriculationController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Immatriculation',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.directions_car, color: _vertMoyen),
              ),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () async {
                    if (_nomController.text.isEmpty || _immatriculationController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez remplir tous les champs'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    
                    setModalState(() => _isLoading = true);
                    
                    try {
                      // 🔴 CORRECTION: Passer widget.user.id comme agentId
                      final response = await ApiService.reserverPlaceVisiteur(
                        place['id'],
                        _nomController.text,
                        _immatriculationController.text,
                        widget.user.id,  // <- L'ID de l'agent connecté
                      );
                      
                      if (!mounted) return;
                      
                      if (response['success'] == true) {
                        // Fermer le dialogue
                        Navigator.pop(ctx);
                        
                        // Recharger les données
                        await _loadData();
                        
                        // Afficher le succès
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ Place réservée pour ${_nomController.text}'),
                            backgroundColor: _vertMoyen,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else {
                        setModalState(() => _isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response['message'] ?? 'Erreur lors de la réservation'),
                            backgroundColor: _rouge,
                          ),
                        );
                      }
                    } catch (e) {
                      setModalState(() => _isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur: $e'),
                          backgroundColor: _rouge,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(backgroundColor: _vertMoyen),
            child: const Text('Réserver'),
          ),
        ],
      ),
    ),
  );
}

  Future<void> _libererPlaceVisiteur(Map<String, dynamic> place) async {
    if (!mounted) return;
    
    final response = await ApiService.libererPlaceVisiteur(place['id']);
    
    if (!mounted) return;
    
    if (response['success'] == true) {
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Place libérée'),
          backgroundColor: _vertMoyen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Erreur'),
          backgroundColor: _rouge,
        ),
      );
    }
  }

  // ── VÉRIFIER RÉSIDENT ───────────────────────────────────────────
  void _showVerifierResidentDialog(BuildContext context) {
    if (!mounted) return;
    
    final _searchController = TextEditingController();
    Map<String, dynamic>? residentTrouve;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.badge, color: _bleuMoyen),
              const SizedBox(width: 8),
              const Text('Vérifier Résident'),
            ],
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Nom ou appartement (ex: A101)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.search, color: _bleuMoyen),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        final query = _searchController.text;
                        if (query.isEmpty) return;
                        
                        var response = await ApiService.rechercherResidentParNom(query);
                        
                        if (response['success'] != true || response['residents'] == null || response['residents'].isEmpty) {
                          response = await ApiService.rechercherResidentParAppartement(query, '');
                        }
                        
                        if (mounted) {
                          setDlgState(() {
                            if (response['success'] == true && response['residents'] != null && response['residents'].isNotEmpty) {
                              residentTrouve = response['residents'][0];
                            } else {
                              residentTrouve = null;
                            }
                          });
                        }
                      },
                    ),
                  ),
                ),
                if (residentTrouve != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _vertMoyen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _vertMoyen.withOpacity(0.4)),
                    ),
                    child: Column(
                      children: [
                        _infoRow(Icons.person, 'Nom', residentTrouve!['nom']),
                        const Divider(height: 8),
                        _infoRow(Icons.apartment, 'Appartement', residentTrouve!['appartement']),
                        const Divider(height: 8),
                        _infoRow(Icons.local_parking, 'Parking', residentTrouve!['parking']?.toString() ?? 'Non assigné'),
                        const Divider(height: 8),
                        _infoRow(Icons.check_circle, 'Statut', residentTrouve!['statut'] ?? 'Actif'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
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

  // ── ACCÈS VISITEUR ──────────────────────────────────────────────
  void _showAccesVisiteurDialog(BuildContext context) {
    if (!mounted) return;
    
    final _nomController = TextEditingController();
    final _cinController = TextEditingController();
    final _aptController = TextEditingController();
    final _dureeController = TextEditingController(text: '2h');
    DateTime? _dateArrivee = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.vpn_key, color: _bleuMoyen),
              const SizedBox(width: 8),
              const Text('Accès Visiteur'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nomController,
                  decoration: InputDecoration(
                    labelText: 'Nom du visiteur',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.person_outline, color: _bleuMoyen),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _cinController,
                  decoration: InputDecoration(
                    labelText: 'CIN / Passeport',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.credit_card, color: _bleuMoyen),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _aptController,
                  decoration: InputDecoration(
                    labelText: 'Appartement visité (ex: A101)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.apartment, color: _bleuMoyen),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _dureeController,
                        decoration: InputDecoration(
                          labelText: 'Durée',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(Icons.timer, color: _bleuMoyen),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 7)),
                          );
                          if (date != null && mounted) {
                            setDlgState(() {
                              _dateArrivee = date;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          '${_dateArrivee!.day}/${_dateArrivee!.month}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nomController.text.isEmpty ||
                    _cinController.text.isEmpty ||
                    _aptController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir tous les champs'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final accesData = {
                  'nom_visiteur': _nomController.text,
                  'cin': _cinController.text,
                  'appartement_cible': _aptController.text,
                  'duree': _dureeController.text,
                  'date_arrivee': _dateArrivee!.toIso8601String().split('T')[0],
                };

                final response = await ApiService.genererAccesVisiteur(accesData);
                
                if (!mounted) return;
                
                Navigator.pop(context);

                if (response['success'] == true) {
                  _showBadgeDialog(
                    context, 
                    response['code_acces'], 
                    _nomController.text,
                    _aptController.text,
                    _dateArrivee!, 
                    _dureeController.text
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['message'] ?? 'Erreur'),
                      backgroundColor: _rouge,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: _bleuMoyen),
              child: const Text('Générer badge', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDialog(
    BuildContext context, 
    dynamic codeAcces, 
    String nomVisiteur,
    String appartement,
    DateTime dateArrivee, 
    String duree
  ) {
    if (!mounted) return;
    
    String codeString = codeAcces.toString();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                _bleuMoyen.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_bleuMoyen, _vertMoyen],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'BADGE D\'ACCÈS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: codeString,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _bleuMoyen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _bleuMoyen.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'CODE D\'ACCÈS',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      codeString,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _bleuFonce,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildBadgeInfoRow(Icons.person, 'Visiteur', nomVisiteur),
                    const Divider(height: 12),
                    _buildBadgeInfoRow(Icons.apartment, 'Appartement', appartement),
                    const Divider(height: 12),
                    _buildBadgeInfoRow(Icons.access_time, 'Durée', duree),
                    const Divider(height: 12),
                    _buildBadgeInfoRow(Icons.calendar_today, 'Valable jusqu\'au', 
                        '${dateArrivee.day}/${dateArrivee.month}'),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _vertMoyen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _vertMoyen.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: _vertMoyen, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Présentez ce QR code à l\'entrée ou donnez le code à l\'agent',
                        style: TextStyle(
                          fontSize: 12,
                          color: _vertMoyen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _bleuMoyen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'FERMER',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _bleuMoyen),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
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
    );
  }

  Widget _infoRow(IconData icon, String label, dynamic value) {
    String displayValue = value?.toString() ?? 'Non renseigné';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _bleuMoyen),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(
            child: Text(
              displayValue,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 340,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder(
                future: ApiService.getNotificationsAgent(widget.user.id),
                builder: (context, snapshot) {
                  if (!mounted) return const SizedBox.shrink();
                  
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
                    
                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final n = notifications[index];
                        return _notifTile(
                          Icons.notifications,
                          _bleuMoyen,
                          n['titre'] ?? 'Notification',
                          n['contenu'] ?? '',
                          _formatDate(n['date_creation']),
                        );
                      },
                    );
                  }
                  
                  return const Center(
                    child: Text('Erreur de chargement'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inMinutes < 60) {
        return 'Il y a ${difference.inMinutes}min';
      } else if (difference.inHours < 24) {
        return 'Il y a ${difference.inHours}h';
      } else {
        return '${date.day}/${date.month}';
      }
    } catch (e) {
      return '';
    }
  }

  Widget _notifTile(
      IconData icon, Color color, String title, String subtitle, String time) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
    );
  }

  void _showProfileDialog(BuildContext context) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mon profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: _bleuFonce,
              child: Text(widget.user.nom[0].toUpperCase(),
                  style: const TextStyle(fontSize: 32, color: Colors.white)),
            ),
            const SizedBox(height: 16),
            ProfileInfoRow(Icons.person, 'Nom', widget.user.nom),
            const Divider(),
            ProfileInfoRow(Icons.email, 'Email', widget.user.email),
            const Divider(),
            ProfileInfoRow(Icons.security, 'Rôle', 'Agent Sécurité'),
            const Divider(),
            ProfileInfoRow(Icons.door_front_door, 'Poste', 'Entrée principale'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer')),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Helper class pour _infoRow dans le profil
class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1A3A6B)),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(
            child: Text(value, 
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}