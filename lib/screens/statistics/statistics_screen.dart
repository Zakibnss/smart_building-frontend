import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';
import 'dart:math';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedPeriode = 'Mois';
  
  // Données statistiques
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _reclamationsMensuelles = [];
  List<Map<String, dynamic>> _colisMensuels = [];
  List<Map<String, dynamic>> _servicesMensuels = [];
  
  // Statistiques globales
  int _totalResidents = 0;
  int _totalAgents = 0;
  int _totalTechniciens = 0;
  int _totalReclamations = 0;
  int _totalColis = 0;
  int _totalServices = 0;
  int _totalMissions = 0;
  double _tauxOccupationParking = 0;
  double _tauxSatisfaction = 85.5;
  
  // Couleurs
  final Color _bleuFonce = const Color(0xFF0D1F3C);
  final Color _bleuMoyen = const Color(0xFF1A3A6B);
  final Color _vertMoyen = const Color(0xFF4CAF50);
  final Color _orange = const Color(0xFFFF9800);
  final Color _rouge = const Color(0xFFF44336);
  final Color _violet = const Color(0xFF9C27B0);
  final Color _cyan = const Color(0xFF00BCD4);
  final Color _gris = const Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      final stats = await ApiService.getAdminStats();
      
      if (stats['success'] == true) {
        var data = stats['stats'] ?? {};
        
        setState(() {
          _totalResidents = data['total_residents'] ?? 0;
          _totalAgents = (data['total_security'] ?? 0) + (data['total_service'] ?? 0);
          _totalTechniciens = data['total_technicians'] ?? 0;
          _totalReclamations = data['total_reclamations'] ?? 0;
          _totalMissions = data['total_missions'] ?? 0;
          _tauxOccupationParking = data['parking_occupation']?.toDouble() ?? 0;
          _stats = data;
        });
      }
      
      await _loadMonthlyData();
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMonthlyData() async {
    // Simuler des données mensuelles
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Données des 6 derniers mois
    List<String> mois = ['Oct', 'Nov', 'Déc', 'Jan', 'Fév', 'Mar'];
    
    setState(() {
      _reclamationsMensuelles = [
        {'mois': 'Oct', 'count': 5},
        {'mois': 'Nov', 'count': 8},
        {'mois': 'Déc', 'count': 12},
        {'mois': 'Jan', 'count': 7},
        {'mois': 'Fév', 'count': 4},
        {'mois': 'Mar', 'count': 6},
      ];
      
      _colisMensuels = [
        {'mois': 'Oct', 'count': 15},
        {'mois': 'Nov', 'count': 22},
        {'mois': 'Déc', 'count': 35},
        {'mois': 'Jan', 'count': 28},
        {'mois': 'Fév', 'count': 20},
        {'mois': 'Mar', 'count': 18},
      ];
      
      _servicesMensuels = [
        {'mois': 'Oct', 'count': 8},
        {'mois': 'Nov', 'count': 12},
        {'mois': 'Déc', 'count': 18},
        {'mois': 'Jan', 'count': 15},
        {'mois': 'Fév', 'count': 10},
        {'mois': 'Mar', 'count': 14},
      ];
      
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Statistiques',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _bleuFonce,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cartes KPI
                      _buildKPIGrid(),
                      const SizedBox(height: 24),
                      
                      // Graphique des réclamations
                      _buildChartCard(
                        title: 'Évolution des réclamations',
                        icon: Icons.report_problem,
                        color: Colors.orange,
                        child: _buildLineChart(_reclamationsMensuelles, Colors.orange),
                      ),
                      const SizedBox(height: 16),
                      
                      // Graphique des colis
                      _buildChartCard(
                        title: 'Évolution des colis',
                        icon: Icons.inventory_2,
                        color: Colors.green,
                        child: _buildLineChart(_colisMensuels, Colors.green),
                      ),
                      const SizedBox(height: 16),
                      
                      // Graphique des services
                      _buildChartCard(
                        title: 'Évolution des services',
                        icon: Icons.build,
                        color: _bleuMoyen,
                        child: _buildLineChart(_servicesMensuels, _bleuMoyen),
                      ),
                      const SizedBox(height: 24),
                      
                      // Statistiques parking
                      _buildParkingStats(),
                      const SizedBox(height: 24),
                      
                      // Répartition par catégorie
                      _buildCategoryStats(),
                      const SizedBox(height: 24),
                      
                      // Taux de satisfaction
                      _buildSatisfactionCard(),
                      const SizedBox(height: 16),
                    ],
                  ),
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
              onPressed: _loadStatistics,
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

  Widget _buildKPIGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildKPIcard(
          title: 'Résidents',
          value: '$_totalResidents',
          icon: Icons.people,
          color: _bleuMoyen,
          trend: '+12%',
        ),
        _buildKPIcard(
          title: 'Agents',
          value: '$_totalAgents',
          icon: Icons.security,
          color: _vertMoyen,
          trend: '+5%',
        ),
        _buildKPIcard(
          title: 'Techniciens',
          value: '$_totalTechniciens',
          icon: Icons.handyman,
          color: _cyan,
          trend: '+8%',
        ),
        _buildKPIcard(
          title: 'Réclamations',
          value: '$_totalReclamations',
          icon: Icons.report_problem,
          color: Colors.orange,
          trend: '-15%',
          negative: true,
        ),
        _buildKPIcard(
          title: 'Missions',
          value: '$_totalMissions',
          icon: Icons.assignment,
          color: _violet,
          trend: '+22%',
        ),
        _buildKPIcard(
          title: 'Parking',
          value: '${_tauxOccupationParking.toInt()}%',
          icon: Icons.local_parking,
          color: _bleuFonce,
          trend: '+3%',
        ),
      ],
    );
  }

  Widget _buildKPIcard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? trend,
    bool negative = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: negative ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        negative ? Icons.arrow_downward : Icons.arrow_upward,
                        size: 10,
                        color: negative ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend,
                        style: TextStyle(
                          fontSize: 9,
                          color: negative ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<Map<String, dynamic>> data, Color color) {
    if (data.isEmpty) return const Center(child: Text('Aucune donnée'));
    
    double maxY = data.map((e) => e['count'] as int).reduce((a, b) => a > b ? a : b).toDouble();
    maxY = (maxY / 10).ceil() * 10;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 4,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[index]['mois'],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value['count'].toDouble());
            }).toList(),
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _bleuMoyen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.local_parking, color: _bleuMoyen, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Occupation du parking',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: CircularProgressIndicator(
                            value: _tauxOccupationParking / 100,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(_bleuMoyen),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '${_tauxOccupationParking.toInt()}%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _bleuMoyen,
                              ),
                            ),
                            const Text(
                              'Occupé',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${((100 - _tauxOccupationParking) / 100 * 50).toInt()} places libres',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildParkingStatItem('Places résidents', '30', _bleuMoyen),
                    const SizedBox(height: 12),
                    _buildParkingStatItem('Places visiteurs', '20', _orange),
                    const SizedBox(height: 12),
                    _buildParkingStatItem('Places handicapés', '5', _vertMoyen),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParkingStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _violet.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.pie_chart, color: _violet, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Répartition par catégorie',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildCategoryItem('Électricité', 30, Colors.orange),
              _buildCategoryItem('Plomberie', 25, _bleuMoyen),
              _buildCategoryItem('Nettoyage', 20, _vertMoyen),
              _buildCategoryItem('Autre', 25, _gris),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String label, int percentage, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSatisfactionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_bleuMoyen, _bleuFonce],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Satisfaction résidents',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_tauxSatisfaction.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < (_tauxSatisfaction / 20).floor()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.thumb_up,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}