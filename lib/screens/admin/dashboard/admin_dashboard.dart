import 'package:flutter/material.dart';
import 'package:smart_residence/services/api_service.dart';
import '../users_management/residents/residents_list_screen.dart';
import '../users_management/security_agents/security_agents_list_screen.dart';
import '../users_management/service_agents/service_agents_list_screen.dart';
import '../users_management/technicians/technicians_list_screen.dart';

class AdminDashboard extends StatefulWidget {
  final String userName;

  const AdminDashboard({Key? key, required this.userName}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  
  // Statistiques dynamiques
  int _residents = 0;
  int _agents = 0;
  int _reclamations = 0;
  int _missions = 0;
  int _parking = 0;
  int _technicians = 0;
  bool _isLoading = true;
  
  // Activités récentes dynamiques
  List<Map<String, dynamic>> _recentActivities = [];
  
  // Palette de couleurs selon les spécifications
  final Color primaryBlue = Color(0xFF1E3A5F);  // Bleu foncé (sidebar)
  final Color mediumBlue = Color(0xFF2F6F8F);   // Bleu moyen (header)
  final Color lightBlue = Color(0xFF5FA8C5);    // Bleu clair (accents)
  final Color lightGreen = Color(0xFF7BBF9A);   // Vert clair (accents secondaires)
  final Color lightGray = Color(0xFF9AA4A6);    // Gris clair (textes secondaires)
  final Color darkGray = Color(0xFF4A4A4A);     // Gris foncé (textes)
  
  // Gradient de fond
  final LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Color(0xFFE6F0F4), // Bleu très clair
      Color(0xFFE9F2E7), // Vert très clair
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _loadStatistics();
    _loadRecentActivities();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    
    try {
      final stats = await ApiService.getAdminStats();
      
      if (stats['success'] == true) {
        setState(() {
          var data = stats['stats'] ?? {};
          
          _residents = data['total_residents'] ?? 0;
          _agents = (data['total_security'] ?? 0) + (data['total_service'] ?? 0);
          _reclamations = data['total_reclamations'] ?? 0;
          _missions = data['total_missions'] ?? 0;
          _parking = (data['parking_occupation']?.toDouble() ?? 0).toInt();
          _technicians = data['total_technicians'] ?? 0;
          _isLoading = false;
          
          print('✅ Stats chargées: Résidents=$_residents, Agents=$_agents');
        });
      } else {
        _setFallbackStats();
      }
    } catch (e) {
      print('❌ Erreur chargement stats: $e');
      _setFallbackStats();
    }
  }

  void _setFallbackStats() {
    setState(() {
      _residents = 24;
      _agents = 12;
      _reclamations = 8;
      _missions = 15;
      _parking = 78;
      _technicians = 8;
      _isLoading = false;
    });
  }

  Future<void> _loadRecentActivities() async {
    try {
      final response = await ApiService.getRecentActivities();
      if (response['success'] == true) {
        setState(() {
          _recentActivities = List<Map<String, dynamic>>.from(response['activities'] ?? []);
        });
        print('✅ Activités chargées: ${_recentActivities.length}');
      }
    } catch (e) {
      print('❌ Erreur chargement activités: $e');
    }
  }

  // Liste des pages principales
  Widget _getCurrentPage() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryBlue),
            SizedBox(height: 20),
            Text('Chargement des données...', style: TextStyle(color: darkGray)),
          ],
        ),
      );
    }
    
    if (_selectedIndex == 0) {
      return _buildDashboardContent();
    } else if (_selectedIndex == 1) {
      return _buildUserManagementMenu();
    } else if (_selectedIndex == 2) {
      return Center(child: Text('Page Réclamations'));
    } else if (_selectedIndex == 3) {
      return Center(child: Text('Page Statistiques'));
    }
    return _buildDashboardContent();
  }

  // Menu principal de gestion des utilisateurs
  Widget _buildUserManagementMenu() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: backgroundGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestion des utilisateurs',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.1,
              children: [
                _buildUserManagementCard(
                  title: 'Résidents',
                  icon: Icons.people,
                  color: lightBlue,
                  count: _residents,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResidentsListScreen(),
                      ),
                    );
                  },
                ),
                _buildUserManagementCard(
                  title: 'Agents',
                  icon: Icons.security,
                  color: lightGreen,
                  count: _agents,
                  onTap: () {
                    _showAgentSubMenu();
                  },
                ),
                _buildUserManagementCard(
                  title: 'Techniciens',
                  icon: Icons.handyman,
                  color: mediumBlue,
                  count: _technicians,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TechniciansListScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Sous-menu pour les agents
  void _showAgentSubMenu() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        height: 280,
        decoration: BoxDecoration(
          gradient: backgroundGradient,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type d\'agent',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            SizedBox(height: 20),
            _buildAgentTile(
              icon: Icons.security,
              color: lightBlue,
              title: 'Agents de sécurité',
              subtitle: 'Gérer les agents de sécurité',
              screen: SecurityAgentsListScreen(),
            ),
            SizedBox(height: 12),
            _buildAgentTile(
              icon: Icons.build,
              color: lightGreen,
              title: 'Agents de service',
              subtitle: 'Gérer les agents de service',
              screen: ServiceAgentsListScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Widget screen,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkGray,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: lightGray,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: color, size: 16),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }

  // Carte pour le menu de gestion des utilisateurs
  Widget _buildUserManagementCard({
    required String title,
    required IconData icon,
    required Color color,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 50),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Items du menu latéral (sidebar)
  Widget _buildSideMenuItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? lightGreen : Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? lightGreen : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: primaryBlue.withOpacity(0.3),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context); // Fermer le drawer après sélection
      },
    );
  }

  // Drawer personnalisé
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: primaryBlue,
      child: Column(
        children: [
          // En-tête du drawer
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue, mediumBlue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Text(
                    widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'A',
                    style: TextStyle(
                      fontSize: 32,
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  widget.userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Administrateur',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSideMenuItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Tableau de bord',
                  index: 0,
                ),
                _buildSideMenuItem(
                  icon: Icons.people_outline,
                  title: 'Gestion des utilisateurs',
                  index: 1,
                ),
                _buildSideMenuItem(
                  icon: Icons.report_problem_outlined,
                  title: 'Réclamations',
                  index: 2,
                ),
                _buildSideMenuItem(
                  icon: Icons.bar_chart,
                  title: 'Statistiques',
                  index: 3,
                ),
              ],
            ),
          ),
          // Bouton déconnexion
          Container(
            padding: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _showLogoutDialog,
              icon: Icon(Icons.logout, color: Colors.white),
              label: Text('Déconnexion', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  // Fonction de déconnexion améliorée
  Future<void> _logout() async {
    try {
      await ApiService.logout();
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    } finally {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // Dialogue de confirmation de déconnexion
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Déconnexion',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: TextStyle(fontSize: 16, color: darkGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(fontSize: 16, color: lightGray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Déconnecter',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mediumBlue,
        elevation: 4,
        title: Text(
          _selectedIndex == 0 
              ? 'ADMINISTRATION' 
              : (_selectedIndex == 1 
                  ? 'Gestion des utilisateurs' 
                  : (_selectedIndex == 2 ? 'Réclamations' : 'Statistiques')),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.white, size: 28),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                onPressed: () {},
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: lightGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: backgroundGradient,
        ),
        child: _getCurrentPage(),
      ),
    );
  }

  // ========== CONTENU DU TABLEAU DE BORD ==========
  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bannière avec GRAND LOGO
          Container(
            width: double.infinity,
            height: 320,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryBlue,
                  mediumBlue,
                  lightBlue,
                  lightGreen,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Cercles décoratifs
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: 20,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightGreen.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 80,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.03),
                    ),
                  ),
                ),

                // GRAND LOGO CENTRÉ
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'images/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.white.withOpacity(0.2),
                                child: Icon(
                                  Icons.apartment,
                                  size: 100,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Texte de bienvenue
                Positioned(
                  left: 24,
                  bottom: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, ${widget.userName}!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black38, blurRadius: 6)],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Voici un résumé du complexe',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Cartes statistiques
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Résidents',
                        value: '$_residents',
                        icon: Icons.people,
                        accentColor: lightBlue,
                        onTap: () {},
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Agents',
                        value: '$_agents',
                        icon: Icons.security,
                        accentColor: lightGreen,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Réclamations',
                        value: '$_reclamations',
                        icon: Icons.report_problem,
                        accentColor: Colors.orange,
                        onTap: () {},
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Missions',
                        value: '$_missions',
                        icon: Icons.assignment,
                        accentColor: mediumBlue,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Parking',
                        value: '$_parking%',
                        icon: Icons.local_parking,
                        accentColor: primaryBlue,
                        onTap: () {},
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Techniciens',
                        value: '$_technicians',
                        icon: Icons.handyman,
                        accentColor: lightBlue,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Activité récente DYNAMIQUE
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: lightGray.withOpacity(0.2),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gradient header bar
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryBlue, lightGreen],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Text(
                          'ACTIVITÉ RÉCENTE',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: _recentActivities.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    'Aucune activité récente',
                                    style: TextStyle(color: lightGray),
                                  ),
                                ),
                              )
                            : Column(
                                children: _recentActivities.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  Map<String, dynamic> activity = entry.value;
                                  bool isLast = index == _recentActivities.length - 1;
                                  
                                  return _buildActivityItem(
                                    icon: _getIconForType(activity['icon'] ?? ''),
                                    iconColor: _getColorForType(activity['color'] ?? ''),
                                    text: activity['description'] ?? '',
                                    time: activity['time'] ?? '',
                                    isLast: isLast,
                                  );
                                }).toList(),
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
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.2),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
          border: Border(left: BorderSide(color: accentColor, width: 5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: darkGray,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String text,
    required String time,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: darkGray,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 13,
                    color: lightGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fonction pour obtenir l'icône selon le type
  IconData _getIconForType(String type) {
    switch (type) {
      case 'person_add':
        return Icons.person_add;
      case 'check_circle':
        return Icons.check_circle;
      case 'inventory':
        return Icons.inventory;
      case 'build':
        return Icons.build;
      default:
        return Icons.notifications;
    }
  }

  // Fonction pour obtenir la couleur selon le type
  Color _getColorForType(String color) {
    switch (color) {
      case 'lightBlue':
        return lightBlue;
      case 'lightGreen':
        return lightGreen;
      case 'mediumBlue':
        return mediumBlue;
      case 'orange':
        return Colors.orange;
      default:
        return lightGray;
    }
  }
}