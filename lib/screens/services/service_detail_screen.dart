import 'package:flutter/material.dart';
import '../../../models/user.dart';

class ServiceDetailScreen extends StatefulWidget {
  final User user;
  final String serviceType;
  final IconData serviceIcon;
  final Color serviceColor;

  const ServiceDetailScreen({
    Key? key,
    required this.user,
    required this.serviceType,
    required this.serviceIcon,
    required this.serviceColor,
  }) : super(key: key);

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  // Variables pour la date
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  // Variables pour les champs supplémentaires selon le service
  bool _isUrgent = false;
  String? _selectedCategory;
  
  // Catégories pour le service d'achat
  final List<String> _achatCategories = [
    'Courses alimentaires',
    'Pharmacie',
    'Produits ménagers',
    'Autre'
  ];
  
  // Catégories pour les réparations
  final List<String> _reparationCategories = [
    'Électricité',
    'Plomberie',
    'Électroménager',
    'Autre'
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.serviceColor,
              onPrimary: Colors.white,
              surface: widget.serviceColor.withValues(alpha: 0.1),
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.serviceColor,
              onPrimary: Colors.white,
              surface: widget.serviceColor.withValues(alpha: 0.1),
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veuillez sélectionner une date'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // Afficher un résumé de la demande
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Demande envoyée',
            style: TextStyle(color: widget.serviceColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Service: ${widget.serviceType}'),
              Text('Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
              if (_selectedTime != null)
                Text('Heure: ${_selectedTime!.format(context)}'),
              Text('Description: ${_descriptionController.text}'),
              if (_selectedCategory != null)
                Text('Catégorie: $_selectedCategory'),
              if (_isUrgent)
                Text('Urgent: Oui', style: TextStyle(color: Colors.red)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Retour à la liste des services
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: widget.serviceColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.serviceType,
          style: TextStyle(
            color: widget.serviceColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec icône
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: widget.serviceColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        widget.serviceIcon,
                        color: widget.serviceColor,
                        size: 50,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Demande de ${widget.serviceType.toLowerCase()}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.serviceColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Catégorie (pour Achat et Réparation)
                if (widget.serviceType == 'Achat' || widget.serviceType == 'Réparation')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catégorie',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: (widget.serviceType == 'Achat' 
                            ? _achatCategories 
                            : _reparationCategories).map((category) {
                          return ChoiceChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? category : null;
                              });
                            },
                            selectedColor: widget.serviceColor.withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              color: _selectedCategory == category 
                                  ? widget.serviceColor 
                                  : Colors.grey[700],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // Description
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Décrivez votre demande...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: widget.serviceColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez décrire votre demande';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Sélection de date (CORRIGÉ)
                Text(
                  'Date souhaitée',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null
                              ? 'Sélectionner une date'
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          style: TextStyle(
                            color: _selectedDate == null ? Colors.grey : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        Icon(Icons.calendar_today, color: widget.serviceColor),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Sélection d'heure (optionnelle)
                Text(
                  'Heure souhaitée (optionnelle)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectTime(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedTime == null
                              ? 'Sélectionner une heure'
                              : _selectedTime!.format(context),
                          style: TextStyle(
                            color: _selectedTime == null ? Colors.grey : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        Icon(Icons.access_time, color: widget.serviceColor),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Option urgente
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isUrgent,
                        onChanged: (value) {
                          setState(() {
                            _isUrgent = value ?? false;
                          });
                        },
                        activeColor: widget.serviceColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Urgent',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              'Une intervention rapide est nécessaire',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton de soumission
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.serviceColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Envoyer la demande',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}