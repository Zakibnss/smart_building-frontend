import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/colis.dart';
import '../../services/api_service.dart';

// ==================== CONSTANTES ====================
class AppColors {
  static const Color bleuFonce = Color(0xFF0D1F3C);
  static const Color bleuMoyen = Color(0xFF1A3A6B);
  static const Color bleuCard = Color(0xFF1E4D8C);
  static const Color vertMoyen = Color(0xFF4CAF50);
  static const Color teal = Color(0xFF00897B);
  static const Color orange = Color(0xFFFF9800);
  static const Color rouge = Color(0xFFF44336);
}

// ==================== COLIS SCREEN PRINCIPAL ====================
class ColisScreen extends StatefulWidget {
  final User user;

  const ColisScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ColisScreenState createState() => _ColisScreenState();
}

class _ColisScreenState extends State<ColisScreen> with TickerProviderStateMixin {
  List<Colis> _colis = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // Statistiques
  int _enAttente = 0;
  int _recuperes = 0;
  int _enCours = 0;
  
  // Animation pour le bouton de rafraîchissement
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadColis();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _loadColis() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getColisByUser(widget.user.id);
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        List<Colis> colisList = [];
        if (result['colis'] != null) {
          for (var item in result['colis']) {
            colisList.add(Colis.fromJson(item));
          }
        }
        
        setState(() {
          _colis = colisList;
          _calculerStatistiques();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Erreur de chargement';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  void _calculerStatistiques() {
    _enAttente = _colis.where((c) => 
      c.statut.toLowerCase().contains('attente') || 
      c.statut == 'en_attente'
    ).length;
    
    _recuperes = _colis.where((c) => 
      c.statut.toLowerCase().contains('recupere') || 
      c.statut.toLowerCase().contains('récupéré') ||
      c.statut == 'remis' ||
      c.statut == 'recupere'
    ).length;
    
    _enCours = _colis.where((c) => 
      c.statut.toLowerCase().contains('cours') || 
      c.statut == 'en_cours'
    ).length;
  }

  Future<void> _confirmerReception(int colisId) async {
    if (!mounted) return;
    
    // Animation du bouton de rafraîchissement
    _rotationController.forward().then((_) => _rotationController.reset());
    
    // Afficher une boîte de dialogue de confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la réception'),
        content: const Text('Êtes-vous sûr d\'avoir récupéré ce colis ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Afficher un indicateur de chargement
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final result = await ApiService.markColisAsReceivedResident(colisId, widget.user.id);
      
      if (!mounted) return;
      
      // Fermer l'indicateur de chargement
      Navigator.pop(context);
      
     // Vérifier que result est bien un Map avant d'utiliser []
if (result is Map<String, dynamic> && result['success'] == true) {
  // Recharger la liste complète
  _loadColis();
  
  // Afficher un message de succès
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: const [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 8),
          Text('Colis marqué comme récupéré avec succès'),
        ],
      ),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
} else {
  // Afficher un message d'erreur
  String errorMessage = 'Erreur lors de la confirmation';
  if (result is Map<String, dynamic> && result.containsKey('message')) {
    errorMessage = result['message'];
  }
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(errorMessage),
      backgroundColor: Colors.orange,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
    } catch (e) {
      if (!mounted) return;
      
      // Fermer l'indicateur de chargement en cas d'erreur
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _voirDetailsColis(Colis colis) {
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildColisDetailsSheet(colis),
    );
  }

  Widget _buildColisDetailsSheet(Colis colis) {
    final bool isEnAttente = colis.statut.toLowerCase().contains('attente') || 
                             colis.statut == 'en_attente';
    
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bleuFonce.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: AppColors.bleuFonce,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Détails du colis',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.bleuFonce,
                            ),
                          ),
                          if (colis.codeRetrait != null)
                            Text(
                              'Code: ${colis.codeRetrait}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    _buildStatutBadge(colis.statut),
                  ],
                ),
                const Divider(height: 24),
                
                _buildDetailRow(Icons.person, 'Destinataire', widget.user.nom),
                _buildDetailRow(Icons.calendar_today, 'Date', _formatDate(colis.dateArrivee.toString())),
                _buildDetailRow(Icons.access_time, 'Heure', _formatTime(colis.dateArrivee)),
                _buildDetailRow(Icons.category, 'Type', colis.typeColis),
                if (colis.description.isNotEmpty)
                  _buildDetailRow(Icons.description, 'Description', colis.description),
                if (colis.agentNom != null)
                  _buildDetailRow(Icons.person_outline, 'Enregistré par', colis.agentNom!),
                if (colis.dateRemise != null)
                  _buildDetailRow(Icons.check_circle, 'Récupéré le', _formatDate(colis.dateRemise!.toString())),
                
                const SizedBox(height: 20),
                
                // Bouton Confirmer réception (visible seulement si le colis est en attente)
                if (isEnAttente)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmerReception(colis.id);
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text(
                        'CONFIRMER RÉCEPTION',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 8),
                
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'FERMER',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '';
    try {
      final DateTime dateTime = DateTime.parse(date);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.bleuMoyen),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatutBadge(String statut) {
    Color color;
    String text;
    
    if (statut.toLowerCase().contains('attente') || statut == 'en_attente') {
      color = Colors.orange;
      text = 'En attente';
    } else if (statut.toLowerCase().contains('recupere') || 
               statut.toLowerCase().contains('récupéré') ||
               statut == 'remis' ||
               statut == 'recupere') {
      color = Colors.green;
      text = 'Récupéré';
    } else if (statut.toLowerCase().contains('cours') || statut == 'en_cours') {
      color = AppColors.bleuMoyen;
      text = 'En cours';
    } else {
      color = Colors.grey;
      text = statut;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Color _getStatutColor(String statut) {
    if (statut.toLowerCase().contains('attente') || statut == 'en_attente') {
      return Colors.orange;
    } else if (statut.toLowerCase().contains('recupere') || 
               statut.toLowerCase().contains('récupéré') ||
               statut == 'remis' ||
               statut == 'recupere') {
      return Colors.green;
    } else if (statut.toLowerCase().contains('cours') || statut == 'en_cours') {
      return AppColors.bleuMoyen;
    }
    return Colors.grey;
  }

  IconData _getStatutIcon(String statut) {
    if (statut.toLowerCase().contains('attente') || statut == 'en_attente') {
      return Icons.access_time;
    } else if (statut.toLowerCase().contains('recupere') || 
               statut.toLowerCase().contains('récupéré') ||
               statut == 'remis' ||
               statut == 'recupere') {
      return Icons.check_circle;
    } else if (statut.toLowerCase().contains('cours') || statut == 'en_cours') {
      return Icons.local_shipping;
    }
    return Icons.inventory;
  }

  String _getStatutText(String statut) {
    if (statut.toLowerCase().contains('attente') || statut == 'en_attente') {
      return 'En attente';
    } else if (statut.toLowerCase().contains('recupere') || 
               statut.toLowerCase().contains('récupéré') ||
               statut == 'remis' ||
               statut == 'recupere') {
      return 'Récupéré';
    } else if (statut.toLowerCase().contains('cours') || statut == 'en_cours') {
      return 'En cours';
    }
    return statut;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Mes Colis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.bleuFonce,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Bouton de rafraîchissement avec animation
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * 3.14159,
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadColis,
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _colis.isEmpty
                  ? _buildEmptyState()
                  : _buildColisList(),
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
              onPressed: _loadColis,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bleuFonce,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColisList() {
    return Column(
      children: [
        // Statistiques
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('En attente', _enAttente, Colors.orange),
              _buildStatCard('En cours', _enCours, AppColors.bleuMoyen),
              _buildStatCard('Récupérés', _recuperes, Colors.green),
            ],
          ),
        ),
        
        // Liste des colis
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadColis,
            color: AppColors.bleuMoyen,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _colis.length,
              itemBuilder: (context, index) {
                final colis = _colis[index];
                final bool isEnAttente = colis.statut.toLowerCase().contains('attente') || 
                                         colis.statut == 'en_attente';
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _voirDetailsColis(colis),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _getStatutColor(colis.statut).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getStatutIcon(colis.statut),
                              color: _getStatutColor(colis.statut),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  colis.codeRetrait ?? 'COL-${colis.id}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(colis.dateArrivee.toString()),
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatTime(colis.dateArrivee),
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  colis.typeColis,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatutColor(colis.statut).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _getStatutColor(colis.statut).withOpacity(0.3)),
                                ),
                                child: Text(
                                  _getStatutText(colis.statut),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatutColor(colis.statut),
                                  ),
                                ),
                              ),
                              if (isEnAttente) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 32,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _confirmerReception(colis.id),
                                    icon: const Icon(Icons.check, size: 14),
                                    label: const Text(
                                      'Confirmer',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
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
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun colis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.bleuFonce,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous n\'avez pas encore de colis enregistrés',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadColis,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bleuFonce,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}