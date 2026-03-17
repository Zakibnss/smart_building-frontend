import 'package:flutter/material.dart';
import '../models/user.dart';
import 'profile/profile_screen.dart';
import 'reclamations/reclamations_list_screen.dart';
import 'reclamations/create_reclamation_screen.dart';
import 'colis/colis_screen.dart';
import 'services/services_screen.dart';
import 'parking/parking_screen.dart';
import 'smartmailbox/smartmailbox_screen.dart';

class ResidentDashboard extends StatefulWidget {
  final User user;

  const ResidentDashboard({Key? key, required this.user}) : super(key: key);

  @override
  _ResidentDashboardState createState() => _ResidentDashboardState();
}

class _ResidentDashboardState extends State<ResidentDashboard> {
  int _selectedBottomIndex = 0;

  // Couleurs principales (bleu foncé / vert du logo)
  final Color _bleuFonce = Color(0xFF0D1F3C);
  final Color _bleuMoyen = Color(0xFF1A3A6B);
  final Color _vertMoyen = Color(0xFF4CAF50);
  final Color _vertClair = Color(0xFFC8E6C9);
  final Color _orangeClair = Color(0xFFFFF3E0);
  final Color _bleuClair = Color(0xFFE3F2FD);
  final Color _violetClair = Color(0xFFF3E5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            // Logo bâtiment
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_bleuMoyen, _vertMoyen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.apartment, color: Colors.white, size: 24),
            ),
            SizedBox(width: 12),
            Text(
              'ESPACE RÉSIDENT',
              style: TextStyle(
                color: _bleuFonce,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Icône profil
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: _bleuMoyen.withOpacity(0.15),
              child: Icon(Icons.person, color: _bleuMoyen, size: 18),
            ),
            onPressed: () => _navigateToProfile(context),
          ),
          // Icône cloche avec badge vert
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: _bleuMoyen, size: 26),
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
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 12),

            // ── Carte de bienvenue améliorée ─────────────────────────
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFF5F9FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar avec dégradé
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_bleuMoyen, _vertMoyen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.user.nom[0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenue 👋',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          widget.user.nom,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _bleuFonce,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _bleuClair,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Appartement ${widget.user.numeroAppartement ?? 'A101'} • Bâtiment ${widget.user.batiment ?? 'A'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _bleuMoyen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ── Grille 2×3 des menus améliorée ──────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildMenuCardEnhanced(
                        icon: Icons.campaign,
                        title: 'Faire Réclamation',
                        color: Colors.orange,
                        bgColor: _orangeClair,
                        onTap: () => _navigateToReclamations(context),
                      )),
                      SizedBox(width: 14),
                      Expanded(child: _buildMenuCardEnhanced(
                        icon: Icons.mail,
                        title: 'Smart Mailbox',
                        color: Colors.purple,
                        bgColor: _violetClair,
                        onTap: () => _navigateToSmartMailbox(context),
                      )),
                    ],
                  ),
                  SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _buildMenuCardEnhanced(
                        icon: Icons.inventory_2,
                        title: 'Suivre Colis',
                        color: Color(0xFFB07D3A),
                        bgColor: Color(0xFFFFF8E1),
                        onTap: () => _navigateToColis(context),
                      )),
                      SizedBox(width: 14),
                      Expanded(child: _buildMenuCardEnhanced(
                        icon: Icons.build,
                        title: 'Services',
                        color: Colors.blue,
                        bgColor: _bleuClair,
                        onTap: () => _navigateToServices(context),
                      )),
                    ],
                  ),
                  SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _buildMenuCardEnhanced(
                        icon: Icons.local_parking,
                        title: 'Parking',
                        color: Colors.green,
                        bgColor: _vertClair,
                        onTap: () => _navigateToParking(context),
                      )),
                      SizedBox(width: 14),
                      Expanded(child: _buildMenuCardEnhanced(
                        icon: Icons.person,
                        title: 'Mon Profil',
                        color: _bleuMoyen,
                        bgColor: _bleuClair,
                        onTap: () => _navigateToProfile(context),
                      )),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ── Dernières notifications améliorées ───────────────────
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
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
                        '📬 Dernières notifications',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _bleuFonce,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showNotificationsSheet(context),
                        child: Text(
                          'Voir tout',
                          style: TextStyle(color: _bleuMoyen, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  _buildNotifCard(
                    Icons.inventory_2,
                    Color(0xFFB07D3A),
                    'Colis arrivé',
                    'Votre colis COL123 est disponible',
                    'Il y a 2h',
                  ),
                  SizedBox(height: 8),
                  _buildNotifCard(
                    Icons.check_circle,
                    _vertMoyen,
                    'Réclamation résolue',
                    'Votre réclamation #123 a été traitée',
                    'Hier',
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ── Bouton Déconnexion ─────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: Icon(Icons.logout, size: 16),
                  label: Text('DÉCONNEXION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),

      // ── Bottom Navigation Bar améliorée ───────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(Icons.home, 'Accueil', 0),
                _buildBottomNavItem(Icons.inventory_2, 'Colis', 1),
                _buildBottomNavItem(Icons.local_parking, 'Parking', 2),
                _buildBottomNavItem(Icons.build, 'Services', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCardEnhanced({
    required IconData icon,
    required String title,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
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
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _bleuFonce,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifCard(IconData icon, Color color, String title, String subtitle, String time) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _bleuFonce,
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
            time,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
  final bool selected = _selectedBottomIndex == index;
  return GestureDetector(
    onTap: () {
      setState(() => _selectedBottomIndex = index);
      switch (index) {
        case 0: // Accueil
          break;
        case 1: 
          Navigator.pushNamed(context, '/colis', arguments: widget.user);
          break;
        case 2: 
          Navigator.pushNamed(context, '/parking', arguments: widget.user);
          break;
        case 3: 
          Navigator.pushNamed(context, '/services', arguments: widget.user);
          break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected ? _bleuMoyen : Colors.grey,
            size: 24,
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: selected ? _bleuMoyen : Colors.grey,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
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
  Navigator.pushNamed(
    context, 
    '/colis', 
    arguments: widget.user,  // ← AJOUTER l'argument user
  );
}

void _navigateToServices(BuildContext context) {
  Navigator.pushNamed(
    context, 
    '/services', 
    arguments: widget.user,  // ← AJOUTER l'argument user
  );
}

void _navigateToParking(BuildContext context) {
  Navigator.pushNamed(
    context, 
    '/parking', 
    arguments: widget.user,  // ← AJOUTER l'argument user
  );
}

  // ── Dialogues et Sheets ─────────────────────────────────────────

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnexion'),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Déconnexion', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _bleuFonce),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Tout marquer comme lu',
                    style: TextStyle(fontSize: 12, color: _bleuMoyen),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildNotificationItem(
                    Icons.inventory_2,
                    Color(0xFFB07D3A),
                    'Colis arrivé',
                    'Votre colis COL123 est disponible dans la smart mailbox',
                    'Il y a 2h',
                    false,
                  ),
                  _buildNotificationItem(
                    Icons.check_circle,
                    _vertMoyen,
                    'Réclamation résolue',
                    'Votre réclamation #123 concernant l\'électricité a été résolue',
                    'Hier',
                    false,
                  ),
                  _buildNotificationItem(
                    Icons.local_parking,
                    _bleuMoyen,
                    'Rappel parking',
                    'Votre abonnement parking expire dans 3 jours',
                    'Il y a 2j',
                    true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    IconData icon,
    Color color,
    String title,
    String subtitle,
    String time,
    bool read,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: read ? Colors.grey[50] : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: read ? FontWeight.normal : FontWeight.bold,
                    fontSize: 14,
                    color: _bleuFonce,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
          if (!read)
            Container(
              margin: EdgeInsets.only(left: 8),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}