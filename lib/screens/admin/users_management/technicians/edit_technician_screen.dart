import 'package:flutter/material.dart';
import 'package:smart_residence/models/user.dart';
import 'package:smart_residence/services/api_service.dart';

class EditTechnicianScreen extends StatefulWidget {
  final User technician;

  const EditTechnicianScreen({Key? key, required this.technician}) : super(key: key);

  @override
  _EditTechnicianScreenState createState() => _EditTechnicianScreenState();
}

class _EditTechnicianScreenState extends State<EditTechnicianScreen> {
  late TextEditingController _nomController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _autreSpecialiteController;

  String _selectedSpecialite = 'electricien';
  bool _isLoading = false;
  bool _showAutreChamp = false;

  final List<Map<String, dynamic>> _specialites = [
    {'value': 'electricien', 'label': 'Électricien', 'icon': Icons.electrical_services},
    {'value': 'plombier', 'label': 'Plombier', 'icon': Icons.plumbing},
    {'value': 'maintenance', 'label': 'Maintenance', 'icon': Icons.build},
    {'value': 'nettoyage', 'label': 'Nettoyage', 'icon': Icons.cleaning_services},
    {'value': 'jardinier', 'label': 'Jardinier', 'icon': Icons.yard},
    {'value': 'securite', 'label': 'Sécurité', 'icon': Icons.security},
    {'value': 'autre', 'label': 'Autre', 'icon': Icons.handyman},
  ];

  // Méthode pour vérifier si la spécialité est personnalisée (pas dans la liste)
  bool _isCustomSpecialite(String? specialite) {
    if (specialite == null) return false;
    return !_specialites.any((s) => s['value'] == specialite);
  }

  // Méthode pour obtenir la spécialité finale
  String _getFinalSpecialite() {
    if (_selectedSpecialite == 'autre') {
      return _autreSpecialiteController.text.trim().isEmpty
          ? 'autre'
          : _autreSpecialiteController.text.trim();
    }
    return _selectedSpecialite;
  }

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.technician.nom);
    _emailController = TextEditingController(text: widget.technician.email);
    _telephoneController = TextEditingController(text: widget.technician.telephone ?? '');
    _autreSpecialiteController = TextEditingController();

    // Vérifier si la spécialité actuelle est personnalisée
    String? currentSpecialite = widget.technician.specialite;
    
    if (_isCustomSpecialite(currentSpecialite)) {
      // Si c'est une spécialité personnalisée
      _selectedSpecialite = 'autre';
      _showAutreChamp = true;
      _autreSpecialiteController.text = currentSpecialite ?? '';
    } else {
      // Si c'est une spécialité de la liste
      _selectedSpecialite = currentSpecialite ?? 'electricien';
      _showAutreChamp = false;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _autreSpecialiteController.dispose();
    super.dispose();
  }

  Future<void> _updateTechnician() async {
    if (_nomController.text.isEmpty) {
      _showError('Le nom est requis');
      return;
    }
    if (_emailController.text.isEmpty) {
      _showError('L\'email est requis');
      return;
    }

    // Vérifier que le champ "Autre" n'est pas vide si "Autre" est sélectionné
    if (_selectedSpecialite == 'autre' && _autreSpecialiteController.text.trim().isEmpty) {
      _showError('Veuillez préciser la spécialité');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ApiService.updateTechnician(widget.technician.id, {
        'nom': _nomController.text,
        'email': _emailController.text,
        'telephone': _telephoneController.text,
        'specialite': _getFinalSpecialite(),
      });

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Technicien modifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showError('Erreur lors de la modification');
      }
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier un technicien'),
        backgroundColor: Color(0xFF0F2B4B),
        elevation: 0,
      ),
      body: Container(
        color: Color(0xFFF5F7FA),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modification du technicien',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F2B4B),
                ),
              ),
              SizedBox(height: 20),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Nom et prénom
                      _buildTextField(
                        controller: _nomController,
                        label: 'Nom et prénom',
                        icon: Icons.person,
                        required: true,
                      ),
                      SizedBox(height: 16),

                      // Email
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        required: true,
                      ),
                      SizedBox(height: 16),

                      // Téléphone
                      _buildTextField(
                        controller: _telephoneController,
                        label: 'Téléphone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 16),

                      // Spécialité
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSpecialite,
                            isExpanded: true,
                            items: _specialites.map<DropdownMenuItem<String>>((spec) {
                              return DropdownMenuItem<String>(
                                value: spec['value'] as String,
                                child: Row(
                                  children: [
                                    Icon(spec['icon'] as IconData, color: Color(0xFF2A6FA5), size: 20),
                                    SizedBox(width: 8),
                                    Text(spec['label'] as String),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _selectedSpecialite = value!;
                                _showAutreChamp = (_selectedSpecialite == 'autre');
                                if (!_showAutreChamp) {
                                  _autreSpecialiteController.clear();
                                }
                              });
                            },
                          ),
                        ),
                      ),

                      // Champ "Autre" qui apparaît conditionnellement
                      if (_showAutreChamp) ...[
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: _autreSpecialiteController,
                          label: 'Précisez la spécialité',
                          icon: Icons.edit,
                          required: true,
                        ),
                      ],

                      SizedBox(height: 24),

                      // Boutons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.grey),
                              ),
                              child: Text('Annuler'),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _updateTechnician,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF2A6FA5),
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text('Mettre à jour'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool required = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon: Icon(icon, color: Color(0xFF2A6FA5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF2A6FA5), width: 2),
        ),
      ),
    );
  }
}