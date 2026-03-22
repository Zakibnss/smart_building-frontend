import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';

// ==================== CONSTANTES ====================
class TechColors {
  static const Color bleuFonce = Color(0xFF0D1F3C);
  static const Color bleuMoyen = Color(0xFF1A3A6B);
  static const Color vertMoyen = Color(0xFF4CAF50);
  static const Color orange = Color(0xFFFF9800);
  static const Color violet = Color(0xFF9C27B0);
  static const Color cyan = Color(0xFF00BCD4);
  static const Color rouge = Color(0xFFF44336);
}

// ==================== TECHNICIANS SCREEN ====================
class TechniciansScreen extends StatefulWidget {
  final User user;

  const TechniciansScreen({Key? key, required this.user}) : super(key: key);

  @override
  _TechniciansScreenState createState() => _TechniciansScreenState();
}

class _TechniciansScreenState extends State<TechniciansScreen> with TickerProviderStateMixin {
  List<User> _technicians = [];
  List<User> _filteredTechnicians = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  
  // Animation
  late AnimationController _searchController;
  
  // Filtres
  String _selectedSpecialite = 'Tous';
  List<String> _specialites = ['Tous'];

  @override
  void initState() {
    super.initState();
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadTechnicians();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTechnicians() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getTechnicians();
      
      if (!mounted) return;
      
      setState(() {
        _technicians = result;
        _filteredTechnicians = result;
        _isLoading = false;
        
        // Extraire les spécialités uniques (depuis le rôle ou une propriété)
        // Ici on utilise le rôle comme spécialité par défaut
        _specialites = ['Tous', ...{for (var t in result) t.role}.toList()];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  void _filterTechnicians(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredTechnicians = _technicians.where((tech) {
      // Filtre par recherche
      bool matchesSearch = _searchQuery.isEmpty ||
          tech.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tech.role.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tech.email.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Filtre par spécialité (rôle)
      bool matchesSpecialite = _selectedSpecialite == 'Tous' ||
          tech.role == _selectedSpecialite;
      
      return matchesSearch && matchesSpecialite;
    }).toList();
  }

  Color _getSpecialiteColor(String role) {
    switch (role.toLowerCase()) {
      case 'technicien':
      case 'technicien':
        return TechColors.cyan;
      case 'agent_service':
        return TechColors.vertMoyen;
      case 'agent_securite':
        return TechColors.violet;
      default:
        return TechColors.bleuMoyen;
    }
  }

  IconData _getSpecialiteIcon(String role) {
    switch (role.toLowerCase()) {
      case 'technicien':
        return Icons.handyman;
      case 'agent_service':
        return Icons.build;
      case 'agent_securite':
        return Icons.security;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Équipe Technique',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: TechColors.bleuFonce,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTechnicians,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Barre de recherche
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: _filterTechnicians,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un membre...',
                      prefixIcon: const Icon(Icons.search, color: TechColors.bleuMoyen),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _filteredTechnicians.isEmpty
                  ? _buildEmptyState()
                  : _buildTechniciansList(),
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
              onPressed: _loadTechnicians,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TechColors.bleuFonce,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.handyman_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun membre trouvé',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: TechColors.bleuFonce,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Aucun résultat pour "$_searchQuery"'
                  : 'Aucun technicien disponible pour le moment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTechnicians,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TechColors.bleuFonce,
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

  Widget _buildTechniciansList() {
    return Column(
      children: [
        // Filtres par rôle
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _specialites.length,
            itemBuilder: (context, index) {
              final specialite = _specialites[index];
              final isSelected = _selectedSpecialite == specialite;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(specialite),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSpecialite = specialite;
                      _applyFilters();
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: TechColors.bleuMoyen.withOpacity(0.2),
                  checkmarkColor: TechColors.bleuMoyen,
                  labelStyle: TextStyle(
                    color: isSelected ? TechColors.bleuMoyen : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Résultats de recherche
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '${_filteredTechnicians.length} membre(s) trouvé(s)',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Liste des techniciens
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadTechnicians,
            color: TechColors.bleuMoyen,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _filteredTechnicians.length,
              itemBuilder: (context, index) {
                final tech = _filteredTechnicians[index];
                return _buildTechnicianCard(tech);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicianCard(User tech) {
    final Color specialiteColor = _getSpecialiteColor(tech.role);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showTechnicianDetails(tech),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar avec icône de spécialité
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [specialiteColor, specialiteColor.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getSpecialiteIcon(tech.role),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Informations principales
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tech.nom,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: specialiteColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tech.role,
                            style: TextStyle(
                              fontSize: 12,
                              color: specialiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Indicateur de disponibilité (simulé)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Disponible',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Informations de contact
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.email, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              tech.email,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: Colors.grey[300],
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            tech.telephone ?? 'N/A',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
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
        ),
      ),
    );
  }

  void _showTechnicianDetails(User tech) {
    final Color specialiteColor = _getSpecialiteColor(tech.role);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
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
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [specialiteColor, specialiteColor.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          _getSpecialiteIcon(tech.role),
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tech.nom,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: TechColors.bleuFonce,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: specialiteColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tech.role,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: specialiteColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Informations détaillées
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildDetailInfoRow(
                          Icons.email,
                          'Email',
                          tech.email,
                        ),
                        const Divider(height: 16),
                        _buildDetailInfoRow(
                          Icons.phone,
                          'Téléphone',
                          tech.telephone ?? 'Non renseigné',
                        ),
                        const Divider(height: 16),
                        _buildDetailInfoRow(
                          Icons.badge,
                          'Rôle',
                          tech.role,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Simuler l'appel téléphonique
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Appel à ${tech.nom}...'),
                                backgroundColor: TechColors.vertMoyen,
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text('Appeler'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: TechColors.vertMoyen,
                            side: const BorderSide(color: TechColors.vertMoyen),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Simuler l'envoi d'email
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Email envoyé à ${tech.nom}'),
                                backgroundColor: TechColors.bleuMoyen,
                              ),
                            );
                          },
                          icon: const Icon(Icons.email),
                          label: const Text('Email'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TechColors.bleuMoyen,
                            foregroundColor: Colors.white,
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

  Widget _buildDetailInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: TechColors.bleuMoyen),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}