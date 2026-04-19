import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../services/api_service.dart';
import 'service_detail_screen.dart';

class ServicesScreen extends StatefulWidget {
  final User user;

  const ServicesScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final Color _bleuFonce = const Color(0xFF0D1F3C);
  final Color _bleuMoyen = const Color(0xFF1A3A6B);
  final Color _vertMoyen = const Color(0xFF4CAF50);
  final Color _orange = const Color(0xFFFF9800);
  final Color _rouge = const Color(0xFFF44336);
  final Color _violet = const Color(0xFF9C27B0);
  final Color _cyan = const Color(0xFF00BCD4);
  final Color _jaune = const Color(0xFFFFC107);

  bool _isLoading = true;
  List<Map<String, dynamic>> _demandesRecentes = [];
  Map<String, dynamic> _stats = {};

  final List<Map<String, dynamic>> _services = [
    {
      'icon': Icons.build,
      'title': 'Réparation',
      'subtitle': 'Tous types de réparations',
      'color': const Color(0xFFFF9800),
      'bgColor': const Color(0xFFFFF3E0),
    },
    {
      'icon': Icons.plumbing,
      'title': 'Plomberie',
      'subtitle': 'Fuite, robinet, chasse d\'eau',
      'color': const Color(0xFF00BCD4),
      'bgColor': const Color(0xFFE0F7FA),
    },
    {
      'icon': Icons.cleaning_services,
      'title': 'Nettoyage',
      'subtitle': 'Appartement, parties communes',
      'color': const Color(0xFF4CAF50),
      'bgColor': const Color(0xFFE8F5E9),
    },
    {
      'icon': Icons.local_florist,
      'title': 'Gardien',
      'subtitle': 'Surveillance, accueil',
      'color': const Color(0xFF9C27B0),
      'bgColor': const Color(0xFFF3E5F5),
    },
    {
      'icon': Icons.security,
      'title': 'Sécurité',
      'subtitle': 'Surveillance 24/7',
      'color': const Color(0xFFF44336),
      'bgColor': const Color(0xFFFFEBEE),
    },
    {
      'icon': Icons.electrical_services,
      'title': 'Maintenance',
      'subtitle': 'Électricité, équipements',
      'color': const Color(0xFF3F51B5),
      'bgColor': const Color(0xFFE8EAF6),
    },
    {
      'icon': Icons.shopping_cart,
      'title': 'Achat',
      'subtitle': 'Courses, provisions, livraison',
      'color': const Color(0xFFFFC107),
      'bgColor': const Color(0xFFFFF8E1),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentRequests();
  }

  Future<void> _loadRecentRequests() async {
    setState(() => _isLoading = true);

    try {
      // Charger l'historique des services (pour les demandes récentes)
      final response = await ApiService.getServiceHistory(widget.user.id);
      
      if (response['success'] == true) {
        List<Map<String, dynamic>> allServices = 
            List<Map<String, dynamic>>.from(response['services'] ?? []);
        
        // Prendre les 3 dernières demandes
        setState(() {
          _demandesRecentes = allServices.take(3).toList();
        });
        
        // Calculer les stats
        int total = allServices.length;
        int enCours = allServices.where((s) => 
          s['statut'] == 'en_cours' || s['statut'] == 'assigne' || s['statut'] == 'en_attente'
        ).length;
        
        setState(() {
          _stats = {
            'total': total,
            'en_cours': enCours,
          };
        });
      }
    } catch (e) {
      print('❌ Erreur chargement demandes récentes: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getStatutText(String? statut) {
    switch (statut) {
      case 'en_attente':
        return 'En attente';
      case 'assigne':
        return 'Assigné';
      case 'en_cours':
        return 'En cours';
      case 'termine':
      case 'terminee':
        return 'Terminé';
      default:
        return statut ?? 'Inconnu';
    }
  }

  Color _getStatutColor(String? statut) {
    switch (statut) {
      case 'en_attente':
        return _orange;
      case 'assigne':
        return Colors.blue;
      case 'en_cours':
        return _bleuMoyen;
      case 'termine':
      case 'terminee':
        return _vertMoyen;
      default:
        return Colors.grey;
    }
  }

  IconData _getServiceIcon(String? type) {
    switch (type) {
      case 'Achat':
        return Icons.shopping_cart;
      case 'Plomberie':
        return Icons.plumbing;
      case 'Nettoyage':
        return Icons.cleaning_services;
      default:
        return Icons.build;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Date inconnue';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
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
          'SERVICES RÉSIDENCE',
          style: TextStyle(
            color: _bleuFonce,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: _bleuMoyen),
            onPressed: () => Navigator.pushNamed(
              context, 
              '/service/history', 
              arguments: widget.user,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecentRequests,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecentRequests,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec stats
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Services disponibles',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choisissez le service dont vous avez besoin',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatBadge(
                            _stats['total']?.toString() ?? '0',
                            'Total demandes',
                            Colors.white,
                          ),
                          _buildStatBadge(
                            _stats['en_cours']?.toString() ?? '0',
                            'En cours',
                            _orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Grille des services
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return _buildServiceCard(service);
                  },
                ),

                const SizedBox(height: 24),

                // Section "Mes demandes récentes"
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '📋 Mes demandes récentes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _bleuFonce,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                              context, 
                              '/service/history',
                              arguments: widget.user,
                            ),
                            child: Text(
                              'Voir tout',
                              style: TextStyle(color: _vertMoyen),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_demandesRecentes.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Aucune demande récente',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Commencez par faire une demande',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._demandesRecentes.map((demande) => 
                          _buildRecentRequest(
                            demande['type_service'] ?? 'Service',
                            demande['description'] ?? 'Aucune description',
                            _getStatutText(demande['statut']),
                            _getStatutColor(demande['statut']),
                            demande['date_demande'],
                          )
                        ).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildStatBadge(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(
              user: widget.user,
              serviceType: service['title'],
              serviceIcon: service['icon'],
              serviceColor: service['color'],
            ),
          ),
        );
      },
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
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: service['bgColor'],
                shape: BoxShape.circle,
              ),
              child: Icon(
                service['icon'],
                color: service['color'],
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              service['title'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _bleuFonce,
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                service['subtitle'],
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRequest(String type, String description, String statut, Color statutColor, String? dateStr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statutColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getServiceIcon(type),
              color: statutColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (dateStr != null)
                  Text(
                    _formatDate(dateStr),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
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
              statut,
              style: TextStyle(
                fontSize: 10,
                color: statutColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Accueil', 0, context),
              _buildNavItem(Icons.inventory_2, 'Colis', 1, context),
              _buildNavItem(Icons.local_parking, 'Parking', 2, context),
              _buildNavItem(Icons.shopping_cart, 'Achat', 3, context),
              _buildNavItem(Icons.build, 'Services', 4, context, isSelected: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, BuildContext context, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/resident', arguments: widget.user);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/colis', arguments: widget.user);
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/parking', arguments: widget.user);
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/achat', arguments: widget.user);
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/services', arguments: widget.user);
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? _bleuMoyen : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? _bleuMoyen : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}