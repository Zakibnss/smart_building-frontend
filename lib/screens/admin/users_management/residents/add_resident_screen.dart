import 'package:flutter/material.dart';
import 'package:smart_residence/services/api_service.dart';

class AddResidentScreen extends StatefulWidget {
  @override
  _AddResidentScreenState createState() => _AddResidentScreenState();
}

class _AddResidentScreenState extends State<AddResidentScreen> {
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _appartementController = TextEditingController();
  final _batimentController = TextEditingController();

  bool _isLoading = false;
  bool _hasParking = false;
  bool _hasSmartMailbox = false;

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _appartementController.dispose();
    _batimentController.dispose();
    super.dispose();
  }

  Future<void> _saveResident() async {
    if (_nomController.text.isEmpty) {
      _showError('Le nom est requis');
      return;
    }
    if (_emailController.text.isEmpty) {
      _showError('L\'email est requis');
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showError('Le mot de passe est requis');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ApiService.addResident({
        'nom': _nomController.text,
        'email': _emailController.text,
        'telephone': _telephoneController.text,
        'password': _passwordController.text,
        'numero_appartement': _appartementController.text,
        'batiment': _batimentController.text,
        'role': 'resident',
        'has_parking': _hasParking,
        'has_smartmailbox': _hasSmartMailbox,
      });

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Résident ajouté avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showError('Erreur lors de l\'ajout');
      }
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajouter un résident',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                'Formulaire d\'ajout de résident',
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

                      // Mot de passe
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Mot de passe',
                        icon: Icons.lock,
                        obscureText: true,
                        required: true,
                      ),
                      SizedBox(height: 16),

                      // Appartement et Bâtiment
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _appartementController,
                              label: 'Appartement',
                              icon: Icons.apartment,
                              required: true,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _batimentController,
                              label: 'Bâtiment',
                              icon: Icons.location_on,
                              required: true,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Options
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: Text('Place de parking'),
                              value: _hasParking,
                              onChanged: (value) {
                                setState(() {
                                  _hasParking = value;
                                });
                              },
                              activeColor: Color(0xFF2A6FA5),
                            ),
                            SwitchListTile(
                              title: Text('Boîte aux lettres intelligente'),
                              value: _hasSmartMailbox,
                              onChanged: (value) {
                                setState(() {
                                  _hasSmartMailbox = value;
                                });
                              },
                              activeColor: Color(0xFF2A6FA5),
                            ),
                          ],
                        ),
                      ),
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
                              onPressed: _isLoading ? null : _saveResident,
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
                                  : Text('Sauvegarder'),
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