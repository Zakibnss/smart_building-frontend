import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/archive.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({Key? key}) : super(key: key);

  @override
  _ArchiveScreenState createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> with TickerProviderStateMixin {
  List<ResidentArchive> _archives = [];
  List<ResidentArchive> _filteredArchives = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedPeriode = 'Tous';
  
  // Statistiques
  int _totalArchives = 0;
  int _totalReclamations = 0;
  int _totalColis = 0;
  int _totalServices = 0;
  
  // Couleurs
  final Color _bleuFonce = const Color(0xFF0D1F3C);
  final Color _bleuMoyen = const Color(0xFF1A3A6B);
  final Color _vertMoyen = const Color(0xFF4CAF50);
  final Color _orange = const Color(0xFFFF9800);
  final Color _rouge = const Color(0xFFF44336);
  final Color _gris = const Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _loadArchives();
  }

  Future<void> _loadArchives() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getArchives();
      
      if (response['success'] == true) {
        List<ResidentArchive> archives = [];
        if (response['archives'] != null) {
          for (var item in response['archives']) {
            archives.add(ResidentArchive.fromJson(item));
          }
        }
        
        setState(() {
          _archives = archives;
          _applyFilters();
          _calculerStatistiques();
          _isLoading = false;
        });
        
        print('✅ ${archives.length} archives chargées');
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Erreur de chargement';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  void _calculerStatistiques() {
    _totalArchives = _archives.length;
    _totalReclamations = _archives.fold(0, (sum, a) => sum + a.reclamations.length);
    _totalColis = _archives.fold(0, (sum, a) => sum + a.colis.length);
    _totalServices = _archives.fold(0, (sum, a) => sum + a.services.length);
  }

  void _applyFilters() {
    _filteredArchives = _archives.where((archive) {
      // Filtre par recherche
      bool matchesSearch = _searchQuery.isEmpty ||
          archive.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          archive.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          archive.appartement.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Filtre par période
      bool matchesPeriode = true;
      if (_selectedPeriode != 'Tous') {
        final now = DateTime.now();
        final diff = now.difference(archive.dateSuppression);
        
        switch (_selectedPeriode) {
          case '30 jours':
            matchesPeriode = diff.inDays <= 30;
            break;
          case '3 mois':
            matchesPeriode = diff.inDays <= 90;
            break;
          case '6 mois':
            matchesPeriode = diff.inDays <= 180;
            break;
          case '1 an':
            matchesPeriode = diff.inDays <= 365;
            break;
        }
      }
      
      return matchesSearch && matchesPeriode;
    }).toList();
  }

  void _updateSearch(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  Future<void> _restaurerResident(int residentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurer le résident'),
        content: const Text('Êtes-vous sûr de vouloir restaurer ce résident ?\n\nToutes ses données seront réactivées.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Restaurer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await ApiService.restaurerResident(residentId);
      
      Navigator.pop(context);
      
      if (response['success'] == true) {
        _loadArchives();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Résident restauré avec succès'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Erreur'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _supprimerArchive(int archiveId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer définitivement'),
        content: const Text('Cette action est irréversible. Voulez-vous vraiment supprimer définitivement cette archive ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await ApiService.supprimerResidentArchive(archiveId);
      
      Navigator.pop(context);
      
      if (response['success'] == true) {
        _loadArchives();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archive supprimée définitivement'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Erreur'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Archives des résidents',
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
                      hintText: 'Rechercher un résident...',
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
                    _buildStatChip('Total', _totalArchives.toString(), _bleuMoyen),
                    const SizedBox(width: 8),
                    _buildStatChip('Réclamations', _totalReclamations.toString(), Colors.orange),
                    const SizedBox(width: 8),
                    _buildStatChip('Colis', _totalColis.toString(), Colors.green),
                    const SizedBox(width: 8),
                    _buildStatChip('Services', _totalServices.toString(), _bleuFonce),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadArchives,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _filteredArchives.isEmpty
                  ? _buildEmptyState()
                  : _buildArchivesList(),
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
              onPressed: _loadArchives,
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
              Icons.archive_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune archive',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D1F3C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aucun résident supprimé pour le moment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchivesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _filteredArchives.length,
      itemBuilder: (context, index) {
        final archive = _filteredArchives[index];
        return _buildArchiveCard(archive);
      },
    );
  }

  Widget _buildArchiveCard(ResidentArchive archive) {
    final daysSinceSuppression = DateTime.now().difference(archive.dateSuppression).inDays;
    String periodeText;
    Color periodeColor;
    
    if (daysSinceSuppression <= 30) {
      periodeText = 'Récent';
      periodeColor = Colors.orange;
    } else if (daysSinceSuppression <= 90) {
      periodeText = 'Moyen';
      periodeColor = _bleuMoyen;
    } else {
      periodeText = 'Ancien';
      periodeColor = _gris;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showArchiveDetails(archive),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _bleuMoyen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person_off,
                      color: _bleuMoyen,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          archive.nom,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          archive.appartement,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: periodeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      periodeText,
                      style: TextStyle(
                        fontSize: 11,
                        color: periodeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Statistiques des activités
              Row(
                children: [
                  _buildActivityStat(Icons.report_problem, archive.reclamations.length, Colors.orange),
                  const SizedBox(width: 16),
                  _buildActivityStat(Icons.inventory_2, archive.colis.length, Colors.green),
                  const SizedBox(width: 16),
                  _buildActivityStat(Icons.build, archive.services.length, _bleuMoyen),
                  const SizedBox(width: 16),
                  _buildActivityStat(Icons.vpn_key, archive.accesVisiteurs.length, _bleuFonce),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Période de suppression
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Supprimé le ${archive.dateSuppression.day}/${archive.dateSuppression.month}/${archive.dateSuppression.year}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityStat(IconData icon, int count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showArchiveDetails(ResidentArchive archive) {
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
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _bleuMoyen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.person_off,
                          color: _bleuMoyen,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              archive.nom,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              archive.appartement,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 32),
                  
                  // Informations générales
                  const Text(
                    'Informations générales',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Email', archive.email),
                  _buildDetailRow('Téléphone', archive.telephone),
                  _buildDetailRow('Bâtiment', archive.batiment),
                  _buildDetailRow('Date création', '${archive.dateCreation.day}/${archive.dateCreation.month}/${archive.dateCreation.year}'),
                  _buildDetailRow('Date suppression', '${archive.dateSuppression.day}/${archive.dateSuppression.month}/${archive.dateSuppression.year}'),
                  if (archive.raisonSuppression.isNotEmpty)
                    _buildDetailRow('Raison suppression', archive.raisonSuppression),
                  if (archive.supprimePar != null)
                    _buildDetailRow('Supprimé par', archive.supprimePar!),
                  
                  const SizedBox(height: 24),
                  
                  // Réclamations
                  if (archive.reclamations.isNotEmpty) ...[
                    const Text(
                      'Réclamations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...archive.reclamations.map((r) => _buildActivityTile(
                      Icons.report_problem,
                      Colors.orange,
                      r['titre'],
                      r['description'],
                      r['date_creation'],
                    )),
                    const SizedBox(height: 16),
                  ],
                  
                  // Colis
                  if (archive.colis.isNotEmpty) ...[
                    const Text(
                      'Colis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...archive.colis.map((c) => _buildActivityTile(
                      Icons.inventory_2,
                      Colors.green,
                      c['type_colis'],
                      c['code_retrait'],
                      c['date_arrivee'],
                    )),
                    const SizedBox(height: 16),
                  ],
                  
                  // Services
                  if (archive.services.isNotEmpty) ...[
                    const Text(
                      'Services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...archive.services.map((s) => _buildActivityTile(
                      Icons.build,
                      _bleuMoyen,
                      s['titre'],
                      s['description'],
                      s['date_demande'],
                    )),
                    const SizedBox(height: 16),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _restaurerResident(archive.id);
                          },
                          icon: const Icon(Icons.restore),
                          label: const Text('Restaurer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _supprimerArchive(archive.id);
                          },
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Supprimer définitivement'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  Widget _buildActivityTile(IconData icon, Color color, String title, String subtitle, String date) {
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}