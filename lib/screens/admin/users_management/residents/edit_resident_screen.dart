import 'package:flutter/material.dart';
import 'package:smart_residence/models/resident.dart';
import 'package:smart_residence/services/api_service.dart';


class EditResidentScreen extends StatefulWidget {
  final Resident resident;

  const EditResidentScreen({Key? key, required this.resident}) : super(key: key);

  @override
  _EditResidentScreenState createState() => _EditResidentScreenState();
}

class _EditResidentScreenState extends State<EditResidentScreen> {
  late TextEditingController _nomController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _appartementController;
  late TextEditingController _batimentController;
  late TextEditingController _passwordController;

  bool _isLoading = false;
  bool _changePassword = false;
  bool _hasParking = false;
  bool _hasSmartMailbox = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.resident.nom);
    _emailController = TextEditingController(text: widget.resident.email);
    _telephoneController = TextEditingController(text: widget.resident.telephone);
    _appartementController = TextEditingController(text: widget.resident.numeroAppartement);
    _batimentController = TextEditingController(text: widget.resident.batiment);
    _passwordController = TextEditingController();
    _hasParking = widget.resident.parkingId != null;
    // _hasSmartMailbox = widget.resident.smartMailboxId != null;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _appartementController.dispose();
    _batimentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateResident() async {
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
        'numero_appartement': _appartementController.text,
        'batiment': _batimentController.text,
        'has_parking': _hasParking,
        'has_smartmailbox': _hasSmartMailbox,
      };

      if (_changePassword && _passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }

      final success = await ApiService.updateResident(widget.resident.id, data);

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Résident modifié avec succès'),
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
        title: Text('Modifier un résident'),
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
                'Modification du résident',
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

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _appartementController,
                              label: 'Appartement',
                              icon: Icons.apartment,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _batimentController,
                              label: 'Bâtiment',
                              icon: Icons.location_on,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

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
                              onPressed: _isLoading ? null : _updateResident,
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