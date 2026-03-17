import 'package:flutter/material.dart';
import '../../models/user.dart';

class SmartMailboxScreen extends StatelessWidget {
  final User user;

  const SmartMailboxScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Mailbox'),
        backgroundColor: Color(0xFF0D1F3C),
      ),
      body: Center(
        child: Text('Page Smart Mailbox - À implémenter'),
      ),
    );
  }
}