import 'package:flutter/material.dart';
import '../models/user.dart';

class ServiceDashboard extends StatefulWidget {
  final User user;

  const ServiceDashboard({Key? key, required this.user}) : super(key: key);

  @override
  _ServiceDashboardState createState() => _ServiceDashboardState();
}

class _ServiceDashboardState extends State<ServiceDashboard> {
  int _selectedBottomIndex = 0;
  bool _disponible = true;

  final Color _bleuFonce = Color(0xFF0D1F3C);
  final Color _bleuMoyen = Color(0xFF1A3A6B);
  final Color _vertMoyen = Color(0xFF4CAF50);
  final Color _teal = Color(0xFF009688);

  // Nouvelles missions (en attente d'acceptation)
  List<Map<String, dynamic>> _nouvellesMissions = [
    {
      'id': 'M001',
      'type': 'Plomberie',
      'lieu': 'A101',
      'urgent': true,
      'icon': Icons.build,
    },
    {
      'id': 'M002',
      'type': 'Électricité',
      'lieu': 'B205',
      'urgent': false,
      'icon': Icons.bolt,
    },
  ];

  // Missions acceptées
  List<Map<String, dynamic>> _missionsAcceptees = [
    {
      'id': 'M003',
      'type': 'Nettoyage',
      'lieu': 'Hall',
      'statut': 'En cours',
      'icon': Icons.cleaning_services,
    },
    {
      'id': 'M004',
      'type': 'Réparation',
      'lieu': 'C310',
      'statut': 'Terminé',
      'icon': Icons.bolt,
    },
  ];

  // Stats
  int _missionsMois = 24;
  double _tauxAcceptation = 92;
  int _satisfaction = 4; // sur 5

  @override
  Widget build(BuildContext context) {
    final totalMissions =
        _nouvellesMissions.length + _missionsAcceptees.length;

    return Scaffold(
      backgroundColor: Color(0xFFF0F6FF),
      appBar: AppBar(
        backgroundColor: _bleuFonce,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: Text(
          'AGENT SERVICE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => _showProfileDialog(context),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Colors.white),
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
                    border: Border.all(color: _bleuFonce, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(14),
        child: Column(
          children: [
            // ── Carte agent ─────────────────────────────────────
            _buildAgentCard(),

            SizedBox(height: 14),

            // ── Section MES MISSIONS ─────────────────────────────
            _buildMissionsSection(totalMissions),

            SizedBox(height: 14),

            // ── Section STATISTIQUES ─────────────────────────────
            _buildStatistiquesSection(),

            SizedBox(height: 16),

            // ── LOG OUT ──────────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: Icon(Icons.logout, size: 16),
                label: Text('LOG OUT',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _bleuFonce,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            SizedBox(height: 12),
          ],
        ),
      ),

      // ── Bottom Nav ───────────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── CARTE AGENT ──────────────────────────────────────────────────
  Widget _buildAgentCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A5276), Color(0xFF2980B9)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(Icons.person, color: Colors.white, size: 34),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agent: ${widget.user.nom}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 3),
                Text(
                  'Spécialité: Plomberie/Électricité',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                SizedBox(height: 4),
                // Toggle disponibilité
                GestureDetector(
                  onTap: () =>
                      setState(() => _disponible = !_disponible),
                  child: Row(
                    children: [
                      Text('Disponible: ',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _disponible ? _vertMoyen : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        _disponible ? 'Oui' : 'Non',
                        style: TextStyle(
                            color: _disponible
                                ? Color(0xFF81C784)
                                : Colors.red[300],
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.swap_horiz,
                          color: Colors.white54, size: 14),
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

  // ── SECTION MISSIONS ──────────────────────────────────────────────
  Widget _buildMissionsSection(int total) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _bleuFonce,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.assignment, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'MES MISSIONS ($total)',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.5),
                ),
              ],
            ),
          ),

          // Nouvelles missions
          Padding(
            padding: EdgeInsets.fromLTRB(14, 14, 14, 4),
            child: Text(
              '[Nouvelles missions]',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87),
            ),
          ),

          if (_nouvellesMissions.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text('Aucune nouvelle mission',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            )
          else
            ..._nouvellesMissions
                .map((m) => _buildNouvelleMissionRow(m))
                .toList(),

          Divider(height: 1, color: Colors.grey.shade200),

          // Missions acceptées
          Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Text(
              '[Missions acceptées]',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87),
            ),
          ),

          if (_missionsAcceptees.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text('Aucune mission acceptée',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            )
          else
            ..._missionsAcceptees
                .map((m) => _buildAccepteeMissionRow(m))
                .toList(),

          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildNouvelleMissionRow(Map<String, dynamic> m) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(m['icon'] as IconData,
                  color: _bleuMoyen, size: 16),
              SizedBox(width: 6),
              Text(
                '${m['type']} - ${m['lieu']}',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500),
              ),
              if (m['urgent'] == true) ...[
                SizedBox(width: 6),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'urgent',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 6),
          Row(
            children: [
              // Bouton Accepter
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _accepterMission(m),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text('[Accepter]',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(width: 8),
              // Bouton Refuser
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _refuserMission(m),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text('[Refuser]',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccepteeMissionRow(Map<String, dynamic> m) {
    final bool enCours = m['statut'] == 'En cours';
    final Color statutColor =
        enCours ? Colors.orange : _vertMoyen;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Row(
        children: [
          Icon(m['icon'] as IconData, color: _bleuMoyen, size: 16),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              '${m['type']} - ${m['lieu']}',
              style:
                  TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          // Badge statut cliquable
          GestureDetector(
            onTap: () => _changerStatut(m),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statutColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: statutColor.withOpacity(0.4), width: 1),
              ),
              child: Text(
                m['statut'],
                style: TextStyle(
                    color: statutColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION STATISTIQUES ──────────────────────────────────────────
  Widget _buildStatistiquesSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _bleuFonce,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'STATISTIQUES',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.5),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Missions ce mois
                _buildStatRow(
                  icon: Icons.assignment_turned_in,
                  label: 'Missions ce mois',
                  value: '$_missionsMois',
                  color: _bleuMoyen,
                ),
                SizedBox(height: 10),
                // Taux acceptation
                _buildStatRow(
                  icon: Icons.check_circle_outline,
                  label: "Taux d'acceptation",
                  value: '$_tauxAcceptation%',
                  color: _vertMoyen,
                ),
                SizedBox(height: 10),
                // Satisfaction étoiles
                Row(
                  children: [
                    Icon(Icons.star_rate, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Text('Satisfaction: ',
                        style: TextStyle(
                            fontSize: 14, color: Colors.black87)),
                    Row(
                      children: List.generate(5, (i) {
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _satisfaction = i + 1),
                          child: Icon(
                            i < _satisfaction
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 22,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: ',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        Text(
          value,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color),
        ),
      ],
    );
  }

  // ── BOTTOM NAV ────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.dashboard, 'label': 'DASHBOARD'},
      {'icon': Icons.build, 'label': 'SERVICES'},
      {'icon': Icons.inventory_2, 'label': 'COLIS'},
      {'icon': Icons.local_parking, 'label': 'PARKING'},
      {'icon': Icons.mail_outline, 'label': 'MESSAGES'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = _selectedBottomIndex == i;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedBottomIndex = i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[i]['icon'] as IconData,
                      color: selected ? _bleuFonce : Colors.grey,
                      size: 22,
                    ),
                    SizedBox(height: 2),
                    Text(
                      items[i]['label'] as String,
                      style: TextStyle(
                        fontSize: 9,
                        color: selected ? _bleuFonce : Colors.grey,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── ACTIONS ───────────────────────────────────────────────────────

  void _accepterMission(Map<String, dynamic> m) {
    setState(() {
      _nouvellesMissions.remove(m);
      _missionsAcceptees.insert(0, {
        'id': m['id'],
        'type': m['type'],
        'lieu': m['lieu'],
        'statut': 'En cours',
        'icon': m['icon'],
      });
      _missionsMois++;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text('Mission ${m['type']} acceptée ✓'),
      backgroundColor: _vertMoyen,
    ));
  }

  void _refuserMission(Map<String, dynamic> m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Refuser la mission'),
        content: Text(
            'Confirmer le refus de la mission ${m['type']} - ${m['lieu']} ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _nouvellesMissions.remove(m));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Mission refusée'),
                backgroundColor: Colors.red,
              ));
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Refuser',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _changerStatut(Map<String, dynamic> m) {
    final statuts = ['En cours', 'Terminé', 'En attente'];
    final currentIndex = statuts.indexOf(m['statut']);
    final nextStatut =
        statuts[(currentIndex + 1) % statuts.length];
    setState(() => m['statut'] = nextStatut);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Statut mis à jour: $nextStatut'),
      backgroundColor: _bleuMoyen,
      duration: Duration(seconds: 1),
    ));
  }

  // ── DIALOGUES ─────────────────────────────────────────────────────

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
              child: Text(widget.user.nom[0].toUpperCase(),
                  style:
                      TextStyle(fontSize: 32, color: Colors.white)),
            ),
            SizedBox(height: 16),
            _infoRow(Icons.person, 'Nom', widget.user.nom),
            Divider(),
            _infoRow(Icons.email, 'Email', widget.user.email),
            Divider(),
            _infoRow(Icons.build, 'Rôle', 'Agent Service'),
            Divider(),
            _infoRow(Icons.plumbing, 'Spécialité',
                'Plomberie / Électricité'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fermer')),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _bleuMoyen),
          SizedBox(width: 8),
          Text('$label: ',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(
              child: Text(value, style: TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        height: 340,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _notifTile(
                      Icons.assignment,
                      _bleuMoyen,
                      'Nouvelle mission assignée',
                      'Plomberie urgente - A101',
                      'Il y a 5min'),
                  _notifTile(
                      Icons.check_circle,
                      _vertMoyen,
                      'Mission terminée',
                      'Réparation C310 validée',
                      'Il y a 1h'),
                  _notifTile(
                      Icons.alarm,
                      Colors.orange,
                      'Rappel mission',
                      'Électricité B205 - dans 30min',
                      'Il y a 2h'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notifTile(IconData icon, Color color, String title,
      String subtitle, String time) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 2),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(title,
          style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle:
          Text(subtitle, style: TextStyle(fontSize: 12)),
      trailing: Text(time,
          style: TextStyle(color: Colors.grey, fontSize: 11)),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnexion'),
        content:
            Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler')),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/login'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            child: Text('Déconnexion',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}