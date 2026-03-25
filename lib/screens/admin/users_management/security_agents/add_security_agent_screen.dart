import 'package:flutter/material.dart';

import 'package:smart_residence/services/api_service.dart';


class AddSecurityAgentScreen extends StatefulWidget {
  @override
  _AddSecurityAgentScreenState createState() => _AddSecurityAgentScreenState();
}

class _AddSecurityAgentScreenState extends State<AddSecurityAgentScreen> {
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedStatus = 'Disponible';
  bool _isLoading = false;

  final List<String> _statuses = ['Disponible', 'Absent', 'En congé'];

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveAgent() async {
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
      final success = await ApiService.addSecurityAgent({
        'nom': _nomController.text,
        'email': _emailController.text,
        'telephone': _telephoneController.text,
        'password': _passwordController.text,
        'role': 'agent_securite',
        'status': _selectedStatus,
      });

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agent ajouté avec succès'),
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un agent de sécurité'),
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
                'Formulaire d\'ajout d\'agent',
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
                      _buildTextField(
                        controller: _nomController,
                        label: 'Nom et prénom',
                        icon: Icons.person,
                      ),
                      SizedBox(height: 16),

                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16),

                      _buildTextField(
                        controller: _telephoneController,
                        label: 'Téléphone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 16),

                      _buildTextField(
                        controller: _passwordController,
                        label: 'Mot de passe',
                        icon: Icons.lock,
                        obscureText: true,
                      ),
                      SizedBox(height: 16),

                      // Statut
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatus,
                            isExpanded: true,
                            items: _statuses.map((status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Row(
                                  children: [
                                    Icon(
                                      status == 'Disponible'
                                          ? Icons.check_circle
                                          : status == 'Absent'
                                              ? Icons.cancel
                                              : Icons.access_time,
                                      color: status == 'Disponible'
                                          ? Colors.green
                                          : status == 'Absent'
                                              ? Colors.red
                                              : Colors.orange,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(status),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _selectedStatus = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Annuler'),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveAgent,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF2A6FA5),
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
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
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