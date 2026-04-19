import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../services/api_service.dart';

class ServiceHistoryScreen extends StatefulWidget {
  final User user;

  const ServiceHistoryScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ServiceHistoryScreenState createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  final Color _bleuFonce = const Color(0xFF0D1F3C);
  final Color _bleuMoyen = const Color(0xFF1A3A6B);
  final Color _vertMoyen = const Color(0xFF4CAF50);
  final Color _orange = const Color(0xFFFF9800);
  final Color _rouge = const Color(0xFFF44336);
  
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _historiqueServices = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Charger l'historique des services
      final response = await ApiService.getServiceHistory(widget.user.id);
      
      if (response['success'] == true) {
        setState(() {
          _historiqueServices = List<Map<String, dynamic>>.from(response['services'] ?? []);
        });
        
        // Calculer les statistiques
        _calculerStats();
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Erreur lors du chargement';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculerStats() {
    int total = _historiqueServices.length;
    int enCours = _historiqueServices.where((s) => 
      s['statut'] == 'en_cours' || s['statut'] == 'assigne' || s['statut'] == 'en_attente'
    ).length;
    int termines = _historiqueServices.where((s) => 
      s['statut'] == 'termine' || s['statut'] == 'terminee'
    ).length;
    
    setState(() {
      _stats = {
        'total': total,
        'en_cours': enCours,
        'termines': termines,
      };
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Date non spécifiée';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
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
      case 'Maintenance':
        return Icons.build_circle;
      default:
        return Icons.build;
    }
  }

  Color _getServiceColor(String? type) {
    switch (type) {
      case 'Plomberie':
        return const Color(0xFF00BCD4);
      case 'Électricité':
        return Colors.orange;
      case 'Nettoyage':
        return _vertMoyen;
      case 'Réparation':
        return _orange;
      case 'Sécurité':
        return _rouge;
      case 'Achat':
        return const Color(0xFFFFC107);
      case 'Maintenance':
        return const Color(0xFF3F51B5);
      default:
        return _bleuMoyen;
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
          'HISTORIQUE DES SERVICES',
          style: TextStyle(
            color: _bleuFonce,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
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
                                _buildStatItem(
                                  _stats['total']?.toString() ?? '0', 
                                  'Total', 
                                  Colors.white
                                ),
                                _buildStatItem(
                                  _stats['en_cours']?.toString() ?? '0', 
                                  'En cours', 
                                  _orange
                                ),
                                _buildStatItem(
                                  _stats['termines']?.toString() ?? '0', 
                                  'Terminés', 
                                  Colors.green
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Titre de la liste
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mes demandes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _bleuFonce,
                                ),
                              ),
                              Text(
                                '${_historiqueServices.length} demandes',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Liste des demandes
                          if (_historiqueServices.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucune demande de service',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Vos demandes apparaîtront ici',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _historiqueServices.length,
                              itemBuilder: (context, index) {
                                final service = _historiqueServices[index];
                                return _buildHistoryItem(service);
                              },
                            ),
                        ],
                      ),
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
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> service) {
    String statut = service['statut'] ?? 'en_attente';
    String statutText = _getStatutText(statut);
    Color statutColor = _getStatutColor(statut);
    String typeService = service['type_service'] ?? 'Service';
    IconData icon = _getServiceIcon(typeService);
    Color serviceColor = _getServiceColor(typeService);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: serviceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: serviceColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeService,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _bleuFonce,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(service['date_demande']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statutColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statutText,
                  style: TextStyle(
                    fontSize: 11,
                    color: statutColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            service['description'] ?? 'Aucune description',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (service['heure_souhaitee'] != null && service['heure_souhaitee'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Heure souhaitée: ${service['heure_souhaitee']}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          if (service['priorite'] == 'urgente')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _rouge.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
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
            ),
          if (service['feedback'] != null && service['feedback'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _vertMoyen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.feedback, color: _vertMoyen, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        service['feedback'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
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
              onPressed: _loadHistory,
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
}