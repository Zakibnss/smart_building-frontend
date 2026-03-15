import 'package:flutter/material.dart';
import 'screens/login_secreen.dart';
import 'screens/admin/dashboard/admin_dashboard.dart';
import 'models/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Building',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/admin': (context) {
          // Récupérer l'utilisateur passé en paramètre
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is User) {
            return AdminDashboard(userName: args.nom);
          }
          return AdminDashboard(userName: 'Admin');
        },
      },
    );
  }
}