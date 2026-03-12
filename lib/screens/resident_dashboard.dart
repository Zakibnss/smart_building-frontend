import 'package:flutter/material.dart';
import '../models/user.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F6FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            // Logo bâtiment
            Container(
              width: 36,
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.apartment, color: _bleuMoyen, size: 30),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 28,
                      height: 5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [_vertMoyen, _bleuMoyen]),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Text(
              'ESPACE RÉSIDENT',
              style: TextStyle(
                color: _bleuFonce,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Icône profil
          IconButton(
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: _bleuMoyen.withOpacity(0.15),
              child: Icon(Icons.person, color: _bleuMoyen, size: 18),
            ),
            onPressed: () => _showProfileDialog(context),
          ),
          // Icône cloche avec badge vert
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: _vertMoyen, size: 26),
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

            // ── Carte de bienvenue ──────────────────────────────────
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar circulaire avec fond vert/bleu
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFDFF0FF),
                    child: Icon(Icons.person, color: _bleuMoyen, size: 32),
                  ),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenue ${widget.user.nom}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Appartement ${widget.user.numeroAppartement ?? 'A101'}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ── Grille 2×3 des menus ───────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildMenuCard(
                        imagePath: null,
                        icon: Icons.campaign,
                        title: 'Réclamations',
                        onTap: () => Navigator.pushNamed(context, '/reclamations'),
                      )),
                      SizedBox(width: 14),
                      Expanded(child: _buildMenuCard(
                        imagePath: null,
                        icon: Icons.notifications_active,
                        title: 'Notifications',
                        onTap: () => _showNotificationsSheet(context),
                      )),
                    ],
                  ),
                  SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _buildMenuCard(
                        imagePath: null,
                        icon: Icons.inventory_2,
                        title: 'Mes Colis',
                        onTap: () => Navigator.pushNamed(context, '/colis'),
                      )),
                      SizedBox(width: 14),
                      Expanded(child: _buildMenuCard(
                        imagePath: null,
                        icon: Icons.build,
                        title: 'Services',
                        onTap: () => Navigator.pushNamed(context, '/services'),
                      )),
                    ],
                  ),
                  SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _buildMenuCard(
                        imagePath: null,
                        icon: Icons.local_parking,
                        title: 'Parking',
                        onTap: () => Navigator.pushNamed(context, '/parking'),
                      )),
                      SizedBox(width: 14),
                      Expanded(child: _buildMenuCard(
                        imagePath: null,
                        icon: Icons.mail_outline,
                        title: 'Smart Mailbox',
                        onTap: () => Navigator.pushNamed(context, '/smartmailbox'),
                      )),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ── Dernières notifications ────────────────────────────
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dernières notifications:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  _buildNotifRow(Icons.inventory_2, Color(0xFFB07D3A), 'Colis arrivé - Il y a 2h'),
                  SizedBox(height: 6),
                  _buildNotifRow(Icons.check_circle, _vertMoyen, 'Réclamation résolue - Hier'),
                ],
              ),
            ),

            SizedBox(height: 16),

            // ── Bouton LOG OUT ─────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: Icon(Icons.logout, size: 16),
                  label: Text('LOG OUT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _bleuFonce,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),

      // ── Bottom Navigation Bar ──────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(Icons.dashboard, 'DASHBOARD', 0),
                _buildBottomNavItem(Icons.build, 'SERVICES', 1),
                _buildBottomNavItem(Icons.inventory_2, 'COLIS', 2),
                _buildBottomNavItem(Icons.local_parking, 'PARKING', 3),
                _buildBottomNavItem(Icons.mail_outline, 'MESSAGES', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    String? imagePath,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône colorée illustrée style cartoon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _getIconBgColor(title),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: _getIconColor(title),
              ),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getIconBgColor(String title) {
    switch (title) {
      case 'Réclamations': return Color(0xFFE8F5E9);
      case 'Notifications': return Color(0xFFFFF3E0);
      case 'Mes Colis': return Color(0xFFFFF8E1);
      case 'Services': return Color(0xFFE3F2FD);
      case 'Parking': return Color(0xFFE8F5E9);
      case 'Smart Mailbox': return Color(0xFFE3F2FD);
      default: return Color(0xFFEEEEEE);
    }
  }

  Color _getIconColor(String title) {
    switch (title) {
      case 'Réclamations': return Color(0xFF43A047);
      case 'Notifications': return Color(0xFFFF8F00);
      case 'Mes Colis': return Color(0xFFB07D3A);
      case 'Services': return Color(0xFF1565C0);
      case 'Parking': return Color(0xFF2E7D32);
      case 'Smart Mailbox': return Color(0xFF1565C0);
      default: return Colors.grey;
    }
  }

  Widget _buildNotifRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.black87)),
      ],
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final bool selected = _selectedBottomIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedBottomIndex = index);
        switch (index) {
          case 1: Navigator.pushNamed(context, '/services'); break;
          case 2: Navigator.pushNamed(context, '/colis'); break;
          case 3: Navigator.pushNamed(context, '/parking'); break;
          case 4: Navigator.pushNamed(context, '/smartmailbox'); break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected ? _bleuFonce : Colors.grey,
            size: 22,
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: selected ? _bleuFonce : Colors.grey,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ── Dialogues ────────────────────────────────────────────────────

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

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mon profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: _bleuFonce,
              child: Text(
                widget.user.nom[0].toUpperCase(),
                style: TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            SizedBox(height: 16),
            _buildProfileRow(Icons.person, 'Nom', widget.user.nom),
            Divider(),
            _buildProfileRow(Icons.email, 'Email', widget.user.email),
            Divider(),
            _buildProfileRow(
              Icons.apartment,
              'Appartement',
              widget.user.numeroAppartement ?? 'A101',
            ),
            Divider(),
            _buildProfileRow(Icons.home_work, 'Bâtiment', widget.user.batiment ?? 'N/A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _bleuMoyen),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
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
        height: 380,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notifications',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {},
                  child: Text('Tout marquer comme lu',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildNotifTile(
                    Icons.inventory_2,
                    Color(0xFFB07D3A),
                    'Colis arrivé',
                    'Votre colis COL123 est disponible',
                    'Il y a 2h',
                    false,
                  ),
                  _buildNotifTile(
                    Icons.check_circle,
                    _vertMoyen,
                    'Réclamation résolue',
                    'Votre réclamation #123 a été résolue',
                    'Hier',
                    false,
                  ),
                  _buildNotifTile(
                    Icons.local_parking,
                    _bleuMoyen,
                    'Rappel parking',
                    'Votre accès parking expire dans 3 jours',
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

  Widget _buildNotifTile(
    IconData icon,
    Color color,
    String title,
    String subtitle,
    String time,
    bool read,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 2),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: read ? FontWeight.normal : FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
      trailing: Text(time, style: TextStyle(color: Colors.grey, fontSize: 11)),
    );
  }
}