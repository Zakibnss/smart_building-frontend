import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'profile/profile_screen.dart';
import 'reclamations/reclamations_list_screen.dart';
import 'reclamations/create_reclamation_screen.dart';
import 'colis/colis_screen.dart';
import 'services/services_screen.dart';
import 'parking/parking_screen.dart';
import 'smartmailbox/smartmailbox_screen.dart';
import 'technicians_screen.dart';

// Couleurs pour les techniciens (à définir si pas déjà fait)
class TechColors {
  static const Color violet = Color(0xFF9C27B0);
  static const Color cyan = Color(0xFF00BCD4);
}

class ResidentDashboard extends StatefulWidget {
  final User user;

  const ResidentDashboard({Key? key, required this.user}) : super(key: key);

  @override
  _ResidentDashboardState createState() => _ResidentDashboardState();
}

class _ResidentDashboardState extends State<ResidentDashboard> {
  int _selectedBottomIndex = 0;
  List<Map<String, dynamic>> _notifications = [];
  int _nonLues = 0;
  bool _isLoadingNotifications = false;

  // Couleurs du logo (bleu foncé → vert)
  final Color _bleuFonce = const Color(0xFF0D1F3C);
  final Color _bleuMoyen = const Color(0xFF1A4B7A);
  final Color _bleuClair = const Color(0xFF2A6FA5);
  final Color _vertFonce = const Color(0xFF2E7D32);
  final Color _vertMoyen = const Color(0xFF4CAF50);
  final Color _vertClair = const Color(0xFFC8E6C9);
  
  // Dégradé principal (bleu → vert)
  final LinearGradient _primaryGradient = const LinearGradient(
    colors: [Color(0xFF0D1F3C), Color(0xFF1A4B7A), Color(0xFF2E7D32), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Couleurs de fond pour les cartes
  final Color _orangeClair = const Color(0xFFFFF3E0);
  final Color _violetClair = const Color(0xFFF3E5F5);
  final Color _jauneClair = const Color(0xFFFFF8E1);
  final Color _bleuTresClair = const Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    
    setState(() => _isLoadingNotifications = true);
    
    try {
      final response = await ApiService.getNotificationsResident(widget.user.id);
      
      if (mounted && response['success'] == true) {
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(response['notifications'] ?? []);
          _nonLues = response['non_lues'] ?? 0;
          _isLoadingNotifications = false;
        });
      } else {
        if (mounted) {
          setState(() => _isLoadingNotifications = false);
        }
      }
    } catch (e) {
      print('❌ Erreur chargement notifications: $e');
      if (mounted) {
        setState(() => _isLoadingNotifications = false);
      }
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      await ApiService.markNotificationAsReadResident(notificationId, widget.user.id);
      _loadNotifications(); // Recharger après marquage
    } catch (e) {
      print('❌ Erreur marquage notification: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await ApiService.markAllNotificationsAsRead(widget.user.id);
      _loadNotifications();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Toutes les notifications ont été marquées comme lues'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur marquage toutes: $e');
    }
  }

  String _formatNotifDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inMinutes < 60) {
        return 'Il y a ${difference.inMinutes}min';
      } else if (difference.inHours < 24) {
        return 'Il y a ${difference.inHours}h';
      } else if (difference.inDays == 1) {
        return 'Hier';
      } else if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays}j';
      } else {
        return '${date.day}/${date.month}';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          children: [
            // Logo réel depuis assets
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _bleuFonce.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: _bleuMoyen,
                      child: const Icon(Icons.apartment, color: Colors.white, size: 40),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            ShaderMask(
              shaderCallback: (bounds) => _primaryGradient.createShader(bounds),
              child: Text(
                'ESPACE RÉSIDENT',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Icône profil avec dégradé
          Container(
            decoration: BoxDecoration(
              gradient: _primaryGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.white, size: 20),
              onPressed: () => _navigateToProfile(context),
            ),
          ),
          const SizedBox(width: 4),
          
          // Icône cloche avec badge dynamique
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: _bleuFonce, size: 26),
                onPressed: () => _showNotificationsSheet(context),
              ),
              if (_nonLues > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '$_nonLues',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              _bleuTresClair,
              const Color(0xFFF1F8E9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ── Carte de bienvenue avec dégradé ─────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  gradient: _primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _bleuFonce.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar avec bordure blanche
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          widget.user.nom[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _bleuFonce,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bienvenue 👋',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            widget.user.nom,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.apartment, color: Colors.white70, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  widget.user.adresse ?? 'Appartement non spécifié',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
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

              const SizedBox(height: 24),

              // ── Grille 2×3 des menus avec dégradés ──────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildGradientMenuCard(
                          icon: Icons.campaign,
                          title: 'Faire Réclamation',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                          ),
                          onTap: () => _navigateToReclamations(context),
                        )),
                        const SizedBox(width: 14),
                        Expanded(child: _buildGradientMenuCard(
                          icon: Icons.mail,
                          title: 'Smart Mailbox',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                          ),
                          onTap: () => _navigateToSmartMailbox(context),
                        )),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: _buildGradientMenuCard(
                          icon: Icons.inventory_2,
                          title: 'Suivre Colis',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB07D3A), Color(0xFF8B5E3C)],
                          ),
                          onTap: () => _navigateToColis(context),
                        )),
                        const SizedBox(width: 14),
                        Expanded(child: _buildGradientMenuCard(
                          icon: Icons.build,
                          title: 'Services',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                          ),
                          onTap: () => _navigateToServices(context),
                        )),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: _buildGradientMenuCard(
                          icon: Icons.handyman,
                          title: 'Techniciens',
                          gradient: LinearGradient(
                            colors: [TechColors.violet, TechColors.cyan],
                          ),
                          onTap: () => _navigateToTechnicians(context),
                        )),
                        const SizedBox(width: 14),
                        Expanded(child: _buildGradientMenuCard(
                          icon: Icons.more_horiz,
                          title: 'Autres',
                          gradient: const LinearGradient(
                            colors: [Colors.grey, Colors.grey],
                          ),
                          onTap: () {},
                        )),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: _buildGradientMenuCard(
                          icon: Icons.local_parking,
                          title: 'Parking',
                          gradient: LinearGradient(
                            colors: [_vertMoyen, _vertFonce],
                          ),
                          onTap: () => _navigateToParking(context),
                        )),
                        const SizedBox(width: 14),
                        Expanded(child: _buildGradientMenuCard(
                          icon: Icons.person,
                          title: 'Mon Profil',
                          gradient: _primaryGradient,
                          onTap: () => _navigateToProfile(context),
                        )),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Dernières notifications DYNAMIQUES ───────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, _bleuTresClair],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => _primaryGradient.createShader(bounds),
                              child: const Text(
                                '📬 Dernières notifications',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (_nonLues > 0)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$_nonLues',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => _showNotificationsSheet(context),
                          child: Text(
                            'Voir tout',
                            style: TextStyle(
                              color: _vertMoyen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    _isLoadingNotifications
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _notifications.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text('Aucune notification'),
                                ),
                              )
                            : Column(
                                children: _notifications.take(3).map((notif) {
                                  return _buildDynamicNotifCard(notif);
                                }).toList(),
                              ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Bouton Déconnexion ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('DÉCONNEXION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ── Bottom Navigation Bar avec dégradé ───────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, _bleuTresClair],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
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
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGradientBottomNavItem(Icons.home, 'Accueil', 0),
                _buildGradientBottomNavItem(Icons.inventory_2, 'Colis', 1),
                _buildGradientBottomNavItem(Icons.local_parking, 'Parking', 2),
                _buildGradientBottomNavItem(Icons.build, 'Services', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Carte de menu avec dégradé
  Widget _buildGradientMenuCard({
    required IconData icon,
    required String title,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Carte de notification DYNAMIQUE
  Widget _buildDynamicNotifCard(Map<String, dynamic> notif) {
    // Déterminer l'icône et les couleurs selon le type
    IconData icon;
    Color color1, color2;
    
    switch (notif['type'] ?? 'systeme') {
      case 'colis':
        icon = Icons.inventory_2;
        color1 = const Color(0xFFB07D3A);
        color2 = const Color(0xFF8B5E3C);
        break;
      case 'reclamation':
        icon = Icons.check_circle;
        color1 = _vertMoyen;
        color2 = _vertFonce;
        break;
      case 'parking':
        icon = Icons.local_parking;
        color1 = _bleuMoyen;
        color2 = _bleuClair;
        break;
      default:
        icon = Icons.notifications;
        color1 = Colors.grey;
        color2 = Colors.grey;
    }
    
    bool estLu = notif['est_lu'] == 1;
    
    return GestureDetector(
      onTap: () => _markAsRead(notif['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: estLu
                ? [Colors.grey[50]!, Colors.grey[100]!]
                : [color1.withOpacity(0.1), color2.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: !estLu
              ? Border(left: BorderSide(color: color1, width: 3))
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color1, color2]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif['titre'] ?? 'Notification',
                    style: TextStyle(
                      fontWeight: !estLu ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notif['contenu'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              _formatNotifDate(notif['date_envoi']),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Item de bottom navigation avec dégradé
  Widget _buildGradientBottomNavItem(IconData icon, String label, int index) {
    final bool selected = _selectedBottomIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedBottomIndex = index);
        switch (index) {
          case 0: break; // Accueil - reste sur le dashboard
          case 1: _navigateToColis(context); break;
          case 2: _navigateToParking(context); break;
          case 3: _navigateToServices(context); break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected)
            ShaderMask(
              shaderCallback: (bounds) => _primaryGradient.createShader(bounds),
              child: Icon(icon, color: Colors.white, size: 24),
            )
          else
            Icon(icon, color: Colors.grey, size: 24),
          const SizedBox(height: 2),
          if (selected)
            ShaderMask(
              shaderCallback: (bounds) => _primaryGradient.createShader(bounds),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          else
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  // ── Navigation ──────────────────────────────────────────────────

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(user: widget.user),
      ),
    );
  }

  void _navigateToTechnicians(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TechniciansScreen(user: widget.user),
      ),
    );
  }

  void _navigateToReclamations(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReclamationsListScreen(user: widget.user),
      ),
    );
  }

  void _navigateToCreateReclamation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateReclamationScreen(user: widget.user),
      ),
    );
  }

  void _navigateToSmartMailbox(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SmartMailboxScreen(user: widget.user),
      ),
    );
  }

  void _navigateToColis(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ColisScreen(user: widget.user),
      ),
    );
  }

  void _navigateToServices(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServicesScreen(user: widget.user),
      ),
    );
  }

  void _navigateToParking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParkingScreen(user: widget.user),
      ),
    );
  }

  // ── Dialogues et Sheets ─────────────────────────────────────────

  void _showLogoutDialog(BuildContext context) {
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
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, _bleuTresClair],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => _primaryGradient.createShader(bounds),
                      child: const Text(
                        'Notifications',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    if (_nonLues > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_nonLues',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                if (_nonLues > 0)
                  TextButton(
                    onPressed: _markAllAsRead,
                    child: Text(
                      'Tout marquer',
                      style: TextStyle(fontSize: 12, color: _vertMoyen),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoadingNotifications
                  ? const Center(child: CircularProgressIndicator())
                  : _notifications.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_none, size: 60, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Aucune notification'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notif = _notifications[index];
                            return _buildDynamicNotifCard(notif);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}