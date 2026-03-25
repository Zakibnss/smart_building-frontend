import 'package:flutter/material.dart';
import 'package:smart_residence/models/user.dart';
import 'package:smart_residence/services/api_service.dart';



class EditSecurityAgentScreen extends StatefulWidget {
  final User agent;

  const EditSecurityAgentScreen({Key? key, required this.agent}) : super(key: key);

  @override
  _EditSecurityAgentScreenState createState() => _EditSecurityAgentScreenState();
}

class _EditSecurityAgentScreenState extends State<EditSecurityAgentScreen> {
  late TextEditingController _nomController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _passwordController;

  String _selectedStatus = 'Disponible';
  bool _isLoading = false;
  bool _changePassword = false;

  final List<String> _statuses = ['Disponible', 'Absent', 'En congé'];

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.agent.nom);
    _emailController = TextEditingController(text: widget.agent.email);
    _telephoneController = TextEditingController(text: widget.agent.telephone ?? '');
    _passwordController = TextEditingController();
    _selectedStatus = widget.agent.statut ?? 'Disponible';
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateAgent() async {
    if (_nomController.text.isEmpty) {
      _showError('Le nom est requis');
      return;
    }
    if (_emailController.text.isEmpty) {
      _showError('L\'email est requis');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'nom': _nomController.text,
        'email': _emailController.text,
        'telephone': _telephoneController.text,
        'status': _selectedStatus,
      };

      if (_changePassword && _passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }

      final success = await ApiService.updateSecurityAgent(widget.agent.id, data);

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agent modifié avec succès'),
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
        title: Text('Modifier un agent de sécurité'),
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
                'Modification de l\'agent',
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

                      // Option changer mot de passe
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: Text('Changer le mot de passe'),
                              value: _changePassword,
                              onChanged: (value) {
                                setState(() {
                                  _changePassword = value;
                                });
                              },
                              activeColor: Color(0xFF2A6FA5),
                            ),
                            if (_changePassword)
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: _buildTextField(
                                  controller: _passwordController,
                                  label: 'Nouveau mot de passe',
                                  icon: Icons.lock,
                                  obscureText: true,
                                ),
                              ),
                          ],
                        ),
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
                              onPressed: _isLoading ? null : _updateAgent,
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