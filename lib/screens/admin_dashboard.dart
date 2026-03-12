import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  final User user;

  const AdminDashboard({Key? key, required this.user}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = false;
  Map<String, dynamic> _stats = {};

  // Couleurs du logo
  final Color _bleuFonce = Color(0xFF0D1F3C);
  final Color _bleuMoyen = Color(0xFF1A3A6B);
  final Color _bleuClair = Color(0xFF2A6FA5);
  final Color _vertFonce = Color(0xFF2E7D32);
  final Color _vertMoyen = Color(0xFF4CAF50);
  final Color _vertClair = Color(0xFFC8E6C9);
  final Color _sidebarBg = Color(0xFF0D1F3C);

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    await Future.delayed(Duration(milliseconds: 800));
    setState(() {
      _stats = {
        'residents': 24,
        'agents': 12,
        'reclamations': 8,
        'colis': 45,
        'missions': 15,
        'parking_occupation': 78,
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'ADMINISTRATION',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: _bleuFonce,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          // Notifications
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () => _showNotifications(context),
              ),
              Positioned(
                right: 8,
                top: 10,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _vertMoyen,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Profil avatar
          PopupMenuButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: _bleuFonce, size: 20),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.person_outline, color: _bleuMoyen),
                  title: Text('Mon profil'),
                  contentPadding: EdgeInsets.zero,
                ),
                value: 'profile',
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.settings_outlined, color: _bleuMoyen),
                  title: Text('Paramètres'),
                  contentPadding: EdgeInsets.zero,
                ),
                value: 'settings',
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Déconnexion', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
                value: 'logout',
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context);
              } else if (value == 'profile') {
                _showProfileDialog(context);
              }
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _vertMoyen))
          : _buildBody(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      width: 200,
      child: Container(
        color: _sidebarBg,
        child: Column(
          children: [
            // Drawer header
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
              color: _sidebarBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.user.nom,
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Administrateur',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white12, height: 1),
            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard,
                    title: 'Tableau\nde bord',
                    index: 0,
                  ),
                  _buildDrawerItem(
                    icon: Icons.people,
                    title: 'Résidents',
                    index: 1,
                  ),
                  _buildDrawerItem(
                    icon: Icons.lock,
                    title: 'Agents\nsécurité',
                    index: 2,
                  ),
                  _buildDrawerItem(
                    icon: Icons.build,
                    title: 'Agents\nservice',
                    index: 3,
                  ),
                  _buildDrawerItem(
                    icon: Icons.assignment,
                    title: 'Réclamations',
                    index: 4,
                  ),
                  _buildDrawerItem(
                    icon: Icons.inventory_2,
                    title: 'Colis',
                    index: 5,
                  ),
                  _buildDrawerItem(
                    icon: Icons.local_parking,
                    title: 'Parking',
                    index: 6,
                  ),
                  _buildDrawerItem(
                    icon: Icons.smart_toy,
                    title: 'Smart\nMailbox',
                    index: 7,
                  ),
                  _buildDrawerItem(
                    icon: Icons.bar_chart,
                    title: 'Statistiques',
                    index: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? _vertMoyen : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white54, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: return _buildDashboard();
      case 1: return _buildResidentsList();
      case 2: return _buildSecurityAgentsList();
      case 3: return _buildServiceAgentsList();
      case 4: return _buildComplaintsList();
      case 5: return _buildPackagesList();
      case 6: return _buildParkingManagement();
      case 7: return _buildSmartMailbox();
      case 8: return _buildStatistics();
      default: return _buildDashboard();
    }
  }

  // ─── TABLEAU DE BORD ──────────────────────────────────────────────
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo + Bienvenue
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Building logo image (fallback to icon)
              Container(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.apartment, size: 60, color: _bleuMoyen),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 60,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_vertMoyen, _bleuClair],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, Admin!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Voici un résumé du complexe',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 20),

          // Grille de stats 2x3
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildStatCard2(
                title: 'Résidents',
                value: '${_stats['residents'] ?? 24}',
                icon: Icons.people,
                iconColor: _bleuMoyen,
              ),
              _buildStatCard2(
                title: 'Agents',
                value: '${_stats['agents'] ?? 12}',
                icon: Icons.lock,
                iconColor: _bleuMoyen,
              ),
              _buildStatCard2(
                title: 'Réclamations',
                value: '${_stats['reclamations'] ?? 8}',
                icon: Icons.assignment,
                iconColor: Colors.orange,
              ),
              _buildStatCard2(
                title: 'Colis',
                value: '${_stats['colis'] ?? 45}',
                icon: Icons.inventory_2,
                iconColor: Color(0xFFB07D3A),
              ),
              _buildStatCard2(
                title: 'Missions',
                value: '${_stats['missions'] ?? 15}',
                icon: Icons.build,
                iconColor: Colors.teal,
              ),
              _buildStatCard2(
                title: 'Parking',
                value: '${_stats['parking_occupation'] ?? 78}%',
                icon: Icons.local_parking,
                iconColor: _bleuClair,
              ),
            ],
          ),

          SizedBox(height: 20),

          // Activité récente
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
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
                  'ACTIVITÉ RÉCENTE',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 12),
                _buildActivityRow2(
                  icon: Icons.person_add,
                  color: _bleuMoyen,
                  label: 'Nouveau résident - A101',
                ),
                _buildActivityRow2(
                  icon: Icons.check_circle,
                  color: _vertMoyen,
                  label: 'Réclamation résolue #123',
                ),
                _buildActivityRow2(
                  icon: Icons.inventory_2,
                  color: Color(0xFFB07D3A),
                  label: 'Colis arrivé - F. Zohra',
                ),
                _buildActivityRow2(
                  icon: Icons.build,
                  color: Colors.grey,
                  label: 'Mission assignée - Plomberie',
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Bouton LOG OUT
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: Icon(Icons.logout, color: _bleuMoyen),
              label: Text('LOG OUT', style: TextStyle(color: _bleuMoyen, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _bleuMoyen),
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard2({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: iconColor, size: 26),
        ],
      ),
    );
  }

  Widget _buildActivityRow2({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // ─── RÉSIDENTS ────────────────────────────────────────────────────
  Widget _buildResidentsList() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Résidents', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => _showAddResidentDialog(context),
                  icon: Icon(Icons.add, size: 18),
                  label: Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _vertMoyen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildResidentCard(name: 'Ahmed Benali', apartment: 'A101', phone: '0555123456', email: 'ahmed@email.com'),
                _buildResidentCard(name: 'Fatima Zohra', apartment: 'B205', phone: '0555789012', email: 'fatima@email.com'),
                _buildResidentCard(name: 'Mohamed Boudiaf', apartment: 'C310', phone: '0555345678', email: 'mohamed@email.com'),
                _buildResidentCard(name: 'Karim Hadj', apartment: 'D405', phone: '0555987654', email: 'karim@email.com'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResidentCard({
    required String name,
    required String apartment,
    required String phone,
    required String email,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _bleuMoyen.withOpacity(0.15),
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(color: _bleuFonce, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 2),
                  Text('Apt: $apartment  |  $phone', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text(email, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            IconButton(icon: Icon(Icons.edit, color: _bleuMoyen, size: 20), onPressed: () {}),
            IconButton(icon: Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  // ─── AGENTS SÉCURITÉ ──────────────────────────────────────────────
  Widget _buildSecurityAgentsList() {
    return _buildAgentSection(
      title: 'Agents de sécurité',
      icon: Icons.security,
      agents: [
        {'name': 'Rachid Belkacem', 'shift': 'Matin 6h-14h', 'zone': 'Entrée principale'},
        {'name': 'Sofiane Bouzid', 'shift': 'Soir 14h-22h', 'zone': 'Parking'},
        {'name': 'Hamid Merabet', 'shift': 'Nuit 22h-6h', 'zone': 'Tour B'},
      ],
    );
  }

  // ─── AGENTS SERVICE ───────────────────────────────────────────────
  Widget _buildServiceAgentsList() {
    return _buildAgentSection(
      title: 'Agents de service',
      icon: Icons.build,
      agents: [
        {'name': 'Karim Messaoudi', 'shift': 'Plomberie', 'zone': 'Disponible'},
        {'name': 'Omar Tlemçani', 'shift': 'Électricité', 'zone': 'En mission'},
        {'name': 'Bilal Hadj', 'shift': 'Nettoyage', 'zone': 'Disponible'},
      ],
    );
  }

  Widget _buildAgentSection({
    required String title,
    required IconData icon,
    required List<Map<String, String>> agents,
  }) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.add, size: 18),
                label: Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _bleuMoyen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: agents.length,
            itemBuilder: (context, index) {
              final agent = agents[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _bleuMoyen.withOpacity(0.15),
                    child: Icon(icon, color: _bleuMoyen, size: 20),
                  ),
                  title: Text(agent['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${agent['shift']} • ${agent['zone']}'),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {},
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── RÉCLAMATIONS ─────────────────────────────────────────────────
  Widget _buildComplaintsList() {
    final complaints = [
      {'id': '#123', 'title': 'Problème électrique', 'apt': 'B205', 'status': 'Résolu', 'color': 'green'},
      {'id': '#124', 'title': 'Fuite d\'eau', 'apt': 'A102', 'status': 'En cours', 'color': 'orange'},
      {'id': '#125', 'title': 'Ascenseur en panne', 'apt': 'Tour C', 'status': 'Urgent', 'color': 'red'},
      {'id': '#126', 'title': 'Bruit excessif', 'apt': 'D301', 'status': 'Nouveau', 'color': 'blue'},
    ];
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Text('Réclamations', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: complaints.length,
            itemBuilder: (context, i) {
              final c = complaints[i];
              Color statusColor;
              switch (c['color']) {
                case 'green': statusColor = Colors.green; break;
                case 'orange': statusColor = Colors.orange; break;
                case 'red': statusColor = Colors.red; break;
                default: statusColor = _bleuMoyen;
              }
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.15),
                    child: Text(c['id']!.substring(1, 4), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(c['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Apt: ${c['apt']}'),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(c['status']!, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── COLIS ────────────────────────────────────────────────────────
  Widget _buildPackagesList() {
    final packages = [
      {'code': 'COL123', 'recipient': 'Fatima Zohra', 'apt': 'B205', 'status': 'Livré', 'date': '12/03/2026'},
      {'code': 'COL124', 'recipient': 'Ahmed Benali', 'apt': 'A101', 'status': 'En attente', 'date': '12/03/2026'},
      {'code': 'COL125', 'recipient': 'Karim Hadj', 'apt': 'D405', 'status': 'Récupéré', 'date': '11/03/2026'},
      {'code': 'COL126', 'recipient': 'M. Boudiaf', 'apt': 'C310', 'status': 'Arrivé', 'date': '11/03/2026'},
    ];
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Text('Colis', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: packages.length,
            itemBuilder: (context, i) {
              final p = packages[i];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFB07D3A).withOpacity(0.15),
                    child: Icon(Icons.inventory_2, color: Color(0xFFB07D3A), size: 22),
                  ),
                  title: Text('${p['code']} - ${p['recipient']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('Apt: ${p['apt']} • ${p['date']}'),
                  trailing: Text(p['status']!, style: TextStyle(color: _vertMoyen, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── PARKING ──────────────────────────────────────────────────────
  Widget _buildParkingManagement() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Parking', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildParkingStats(title: 'Résidents', value: '24/30', color: _bleuMoyen)),
                  SizedBox(width: 12),
                  Expanded(child: _buildParkingStats(title: 'Visiteurs', value: '8/10', color: _vertMoyen)),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildParkingSpot('P001', 'Résident', 'Ahmed Benali', true),
              _buildParkingSpot('P002', 'Résident', 'Fatima Zohra', true),
              _buildParkingSpot('P003', 'Résident', null, false),
              _buildParkingSpot('P004', 'Résident', 'Karim Hadj', true),
              _buildParkingSpot('V001', 'Visiteur', 'Visiteur 1', true),
              _buildParkingSpot('V002', 'Visiteur', null, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParkingStats({required String title, required String value, required Color color}) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildParkingSpot(String number, String type, String? occupant, bool occupied) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: occupied ? _vertClair : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.local_parking, color: occupied ? _vertFonce : Colors.grey, size: 20),
        ),
        title: Text('Place $number', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(occupant ?? 'Libre'),
        trailing: Switch(
          value: occupied,
          onChanged: (val) {},
          activeColor: _vertMoyen,
        ),
      ),
    );
  }

  // ─── SMART MAILBOX ────────────────────────────────────────────────
  Widget _buildSmartMailbox() {
    final boxes = [
      {'box': 'MB-01', 'resident': 'Ahmed Benali', 'status': 'Vide', 'last': 'Il y a 2j'},
      {'box': 'MB-02', 'resident': 'Fatima Zohra', 'status': 'Courrier', 'last': 'Il y a 3h'},
      {'box': 'MB-03', 'resident': 'M. Boudiaf', 'status': 'Vide', 'last': 'Il y a 1j'},
      {'box': 'MB-04', 'resident': 'Karim Hadj', 'status': 'Colis', 'last': 'Il y a 30min'},
    ];
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Text('Smart Mailbox', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: boxes.length,
            itemBuilder: (context, i) {
              final b = boxes[i];
              final bool hasContent = b['status'] != 'Vide';
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: hasContent ? _vertClair : Colors.grey[200],
                    child: Icon(Icons.mail, color: hasContent ? _vertFonce : Colors.grey, size: 22),
                  ),
                  title: Text('${b['box']} - ${b['resident']}', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Dernière activité: ${b['last']}'),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: hasContent ? _vertClair : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(b['status']!, style: TextStyle(color: hasContent ? _vertFonce : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── STATISTIQUES ─────────────────────────────────────────────────
  Widget _buildStatistics() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Text('Statistiques', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildBarChart('Réclamations par mois', [8, 12, 6, 15, 10, 8]),
              SizedBox(height: 16),
              _buildBarChart('Colis par semaine', [45, 32, 58, 41, 67, 50]),
              SizedBox(height: 16),
              _buildOccupancyChart(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(String title, List<int> values) {
    final maxVal = values.reduce((a, b) => a > b ? a : b).toDouble();
    final labels = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun'];
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(values.length, (i) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${values[i]}', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: (values[i] / maxVal) * 80,
                      decoration: BoxDecoration(
                        color: _bleuMoyen,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(labels[i], style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyChart() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Occupation parking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('78%', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: _bleuMoyen)),
                    Text('Taux d\'occupation', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 0.78,
                        minHeight: 16,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(_bleuMoyen),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('32/40 places', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── DIALOGUES ────────────────────────────────────────────────────
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
              radius: 40,
              backgroundColor: _bleuFonce,
              child: Text(widget.user.nom[0].toUpperCase(), style: TextStyle(fontSize: 36, color: Colors.white)),
            ),
            SizedBox(height: 16),
            _buildProfileRow(Icons.person, 'Nom', widget.user.nom),
            Divider(),
            _buildProfileRow(Icons.email, 'Email', widget.user.email),
            Divider(),
            _buildProfileRow(Icons.admin_panel_settings, 'Rôle', 'Administrateur'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Fermer')),
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
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddResidentDialog(BuildContext context) {
    final _nomController = TextEditingController();
    final _emailController = TextEditingController();
    final _phoneController = TextEditingController();
    final _aptController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter un résident'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom complet',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person, color: _bleuMoyen),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: _bleuMoyen),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone, color: _bleuMoyen),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _aptController,
                decoration: InputDecoration(
                  labelText: 'Appartement',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.apartment, color: _bleuMoyen),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Résident ajouté avec succès'), backgroundColor: _vertMoyen),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: _vertMoyen),
            child: Text('Ajouter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: Text('Tout lire')),
              ],
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildNotificationItem('Nouveau résident inscrit', 'Ahmed Benali - Apt A101', 'Il y a 10 min', false),
                  _buildNotificationItem('Réclamation urgente', 'Problème électrique - B205', 'Il y a 30 min', false),
                  _buildNotificationItem('Colis arrivé', 'Pour Fatima Zohra - COL123', 'Il y a 1h', true),
                  _buildNotificationItem('Mission terminée', 'Plomberie - Apt C310', 'Il y a 3h', true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String subtitle, String time, bool read) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 2),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: read ? Colors.grey[200] : _bleuClair.withOpacity(0.2),
        child: Icon(Icons.notifications, color: read ? Colors.grey : _bleuFonce, size: 18),
      ),
      title: Text(title, style: TextStyle(fontWeight: read ? FontWeight.normal : FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
      trailing: Text(time, style: TextStyle(color: Colors.grey, fontSize: 11)),
    );
  }
}