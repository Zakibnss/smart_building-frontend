import 'package:flutter/material.dart';
import '../models/user.dart';

class SecurityDashboard extends StatefulWidget {
  final User user;

  const SecurityDashboard({Key? key, required this.user}) : super(key: key);

  @override
  _SecurityDashboardState createState() => _SecurityDashboardState();
}

class _SecurityDashboardState extends State<SecurityDashboard> {
  int _selectedBottomIndex = 0;

  // Couleurs
  final Color _bleuFonce = Color(0xFF0D1F3C);
  final Color _bleuMoyen = Color(0xFF1A3A6B);
  final Color _bleuCard = Color(0xFF1E4D8C);
  final Color _vertMoyen = Color(0xFF4CAF50);
  final Color _teal = Color(0xFF00897B);

  // Données parking visiteurs
  List<Map<String, dynamic>> _parkingVisiteurs = [
    {'id': 'V001', 'libre': true, 'visiteur': null},
    {'id': 'V002', 'libre': false, 'visiteur': 'Visiteur'},
    {'id': 'V003', 'libre': true, 'visiteur': null},
    {'id': 'V004', 'libre': true, 'visiteur': null},
  ];

  // Derniers colis
  final List<Map<String, String>> _colis = [
    {'apt': 'A101', 'heure': '14:30', 'statut': 'En attente'},
    {'apt': 'B205', 'heure': '11:20', 'statut': 'Récupéré'},
    {'apt': 'C310', 'heure': '09:15', 'statut': 'En attente'},
  ];

  @override
  Widget build(BuildContext context) {
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
          'AGENT SÉCURITÉ',
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

            // ── Grille 2×2 actions ───────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.inventory_2,
                    title: 'Enregistrer\nColis',
                    onTap: () => _showEnregistrerColisDialog(context),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.directions_car,
                    title: 'Contrôle\nParking',
                    onTap: () => _showParkingDialog(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.badge,
                    title: 'Vérifier\nRésident',
                    onTap: () => _showVerifierResidentDialog(context),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.vpn_key,
                    title: 'Accès\nVisiteur',
                    onTap: () => _showAccesVisiteurDialog(context),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // ── Derniers colis ───────────────────────────────────
            _buildSection(
              title: 'Derniers colis enregistrés',
              child: Column(
                children: _colis.map((c) => _buildColisRow(c)).toList(),
              ),
            ),

            SizedBox(height: 14),

            // ── Parking visiteurs ────────────────────────────────
            _buildSection(
              title: 'Parking visiteurs',
              child: Column(
                children: _parkingVisiteurs
                    .map((p) => _buildParkingRow(p))
                    .toList(),
              ),
            ),

            SizedBox(height: 16),

            // ── LOG OUT ──────────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: Icon(Icons.logout, size: 16),
                label: Text('LOG OUT',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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

  // ── WIDGETS ──────────────────────────────────────────────────────

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
          Column(
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
                'Poste: Entrée principale',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                'Quart: Jour (08h-16h)',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: _bleuCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _bleuFonce,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
          SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildColisRow(Map<String, String> colis) {
    final bool recupere = colis['statut'] == 'Récupéré';
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            recupere ? Icons.check_circle : Icons.access_time,
            color: recupere ? _vertMoyen : Colors.orange,
            size: 18,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '${colis['apt']} - ${colis['heure']} - ${colis['statut']}',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          if (!recupere)
            GestureDetector(
              onTap: () {
                setState(() => colis['statut'] = 'Récupéré');
              },
              child: Icon(Icons.check_circle_outline,
                  color: Colors.grey, size: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildParkingRow(Map<String, dynamic> place) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: place['libre'] ? _vertMoyen : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '${place['id']}: ',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            place['libre']
                ? 'Libre'
                : 'Occupé (${place['visiteur'] ?? 'Visiteur'})',
            style: TextStyle(
                fontSize: 13,
                color: place['libre'] ? Colors.green[700] : Colors.red[700]),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                place['libre'] = !place['libre'];
                place['visiteur'] = place['libre'] ? null : 'Visiteur';
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: place['libre']
                    ? Colors.red.withOpacity(0.1)
                    : _vertMoyen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: place['libre'] ? Colors.red : _vertMoyen,
                  width: 1,
                ),
              ),
              child: Text(
                place['libre'] ? 'Occuper' : 'Libérer',
                style: TextStyle(
                  fontSize: 11,
                  color: place['libre'] ? Colors.red : _vertMoyen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                onTap: () => setState(() => _selectedBottomIndex = i),
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

  // ── DIALOGUES ────────────────────────────────────────────────────

  void _showEnregistrerColisDialog(BuildContext context) {
    final _aptController = TextEditingController();
    final _descController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [
          Icon(Icons.inventory_2, color: _bleuMoyen),
          SizedBox(width: 8),
          Text('Enregistrer un colis'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _aptController,
              decoration: InputDecoration(
                labelText: 'Appartement destinataire',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.apartment, color: _bleuMoyen),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Description du colis',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description, color: _bleuMoyen),
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _bleuFonce.withOpacity(0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.qr_code, color: _bleuMoyen),
                  SizedBox(width: 8),
                  Text('Code généré automatiquement',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final now = TimeOfDay.now();
              final heure =
                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
              setState(() {
                _colis.insert(0, {
                  'apt': _aptController.text.isEmpty
                      ? 'N/A'
                      : _aptController.text.toUpperCase(),
                  'heure': heure,
                  'statut': 'En attente',
                });
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Colis enregistré avec succès ✓'),
                backgroundColor: _vertMoyen,
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: _bleuMoyen),
            child:
                Text('Enregistrer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showParkingDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contrôle Parking',
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Places visiteurs',
                  style:
                      TextStyle(color: Colors.grey[600], fontSize: 13)),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _parkingVisiteurs.length,
                  itemBuilder: (context, i) {
                    final p = _parkingVisiteurs[i];
                    return ListTile(
                      leading: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: p['libre'] ? _vertMoyen : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text('Place ${p['id']}',
                          style:
                              TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(p['libre']
                          ? 'Libre'
                          : 'Occupé - ${p['visiteur']}'),
                      trailing: Switch(
                        value: !p['libre'],
                        activeColor: Colors.red,
                        inactiveThumbColor: _vertMoyen,
                        onChanged: (val) {
                          setModalState(() {
                            setState(() {
                              p['libre'] = !val;
                              p['visiteur'] = val ? 'Visiteur' : null;
                            });
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVerifierResidentDialog(BuildContext context) {
    final _searchController = TextEditingController();
    final residents = [
      {'nom': 'Ahmed Benali', 'apt': 'A101', 'parking': 'P001', 'statut': 'Actif'},
      {'nom': 'Fatima Zohra', 'apt': 'B205', 'parking': 'P002', 'statut': 'Actif'},
      {'nom': 'Mohamed Boudiaf', 'apt': 'C310', 'parking': 'P003', 'statut': 'Actif'},
    ];
    Map<String, String>? found;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Row(children: [
            Icon(Icons.badge, color: _bleuMoyen),
            SizedBox(width: 8),
            Text('Vérifier Résident'),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Nom ou appartement',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search, color: _bleuMoyen),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      final q = _searchController.text.toLowerCase();
                      setDlgState(() {
                        found = residents.firstWhere(
                          (r) =>
                              r['nom']!.toLowerCase().contains(q) ||
                              r['apt']!.toLowerCase().contains(q),
                          orElse: () => {},
                        );
                        if (found!.isEmpty) found = null;
                      });
                    },
                  ),
                ),
              ),
              if (found != null) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _vertMoyen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _vertMoyen.withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      _infoRow(Icons.person, 'Nom', found!['nom']!),
                      _infoRow(Icons.apartment, 'Appartement', found!['apt']!),
                      _infoRow(Icons.local_parking, 'Parking', found!['parking']!),
                      _infoRow(Icons.check_circle, 'Statut', found!['statut']!),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Fermer')),
          ],
        ),
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
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(value, style: TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  void _showAccesVisiteurDialog(BuildContext context) {
    final _nomController = TextEditingController();
    final _cinController = TextEditingController();
    final _aptController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [
          Icon(Icons.vpn_key, color: _bleuMoyen),
          SizedBox(width: 8),
          Text('Accès Visiteur'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nomController,
              decoration: InputDecoration(
                labelText: 'Nom du visiteur',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline, color: _bleuMoyen),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _cinController,
              decoration: InputDecoration(
                labelText: 'CIN / Passeport',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card, color: _bleuMoyen),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _aptController,
              decoration: InputDecoration(
                labelText: 'Appartement visité',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.apartment, color: _bleuMoyen),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Badge visiteur généré ✓'),
                backgroundColor: _vertMoyen,
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: _bleuMoyen),
            child: Text('Générer badge',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        height: 340,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _notifTile(Icons.inventory_2, Color(0xFFB07D3A),
                      'Colis pour A101', 'En attente de récupération', 'Il y a 30min'),
                  _notifTile(Icons.local_parking, _bleuMoyen,
                      'V002 occupé', 'Place visiteur occupée', 'Il y a 1h'),
                  _notifTile(Icons.person_add, _vertMoyen,
                      'Nouveau visiteur', 'Enregistré pour B205', 'Il y a 2h'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notifTile(
      IconData icon, Color color, String title, String subtitle, String time) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 2),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
      trailing:
          Text(time, style: TextStyle(color: Colors.grey, fontSize: 11)),
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
              child: Text(widget.user.nom[0].toUpperCase(),
                  style: TextStyle(fontSize: 32, color: Colors.white)),
            ),
            SizedBox(height: 16),
            _infoRow(Icons.person, 'Nom', widget.user.nom),
            Divider(),
            _infoRow(Icons.email, 'Email', widget.user.email),
            Divider(),
            _infoRow(Icons.security, 'Rôle', 'Agent Sécurité'),
            Divider(),
            _infoRow(Icons.door_front_door, 'Poste', 'Entrée principale'),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnexion'),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler')),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/login'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Déconnexion',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}