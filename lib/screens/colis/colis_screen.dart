import 'package:flutter/material.dart';
import '../../models/user.dart';

class ColisScreen extends StatelessWidget {
  final User user;

  const ColisScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Colis'),
      ),
      body: Center(
        child: Text('Colis de ${user.nom}'),
      ),
    );
  }
}