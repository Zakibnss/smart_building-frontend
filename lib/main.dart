import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/admin/dashboard/admin_dashboard.dart';
import 'screens/resident_dashboard.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/reclamations/reclamations_list_screen.dart';
import 'screens/reclamations/create_reclamation_screen.dart';
import 'screens/colis/colis_screen.dart';
import 'screens/parking/parking_screen.dart';
import 'screens/services/services_screen.dart';
import 'screens/services/service_history_screen.dart'; // ⚠️ IMPORTANT: Ajoutez cet import
import 'screens/smartmailbox/smartmailbox_screen.dart';
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
        '/login': (context) => const LoginScreen(),
        '/admin': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is User) {
            return AdminDashboard(userName: args.nom);
          }
          return const AdminDashboard(userName: 'Admin');
        },
        '/resident': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is User) {
            return ResidentDashboard(user: args);
          }
          return const LoginScreen();
        },
        '/profile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is User) {
            return ProfileScreen(user: args);
          }
          return const LoginScreen();
        },
        '/reclamations': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is User) {
            return ReclamationsListScreen(user: args);
          }
          return const LoginScreen();
        },
        '/create-reclamation': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is User) {
            return CreateReclamationScreen(user: args);
          }
          return const LoginScreen();
        },
        '/colis': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is User) {
            return ColisScreen(user: args);
          }
          return const LoginScreen();
        },
        '/parking': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is User) {
            return ParkingScreen(user: args);
          }
          return const LoginScreen();
        },
        '/services': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is User) {
            return ServicesScreen(user: args);
          }
          return const LoginScreen();
        },
        // ⚠️ AJOUTEZ CETTE ROUTE CI-DESSOUS :
        '/service/history': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is User) {
            return ServiceHistoryScreen(user: args);
          }
          return const LoginScreen();
        },
        '/smartmailbox': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is User) {
            return SmartMailboxScreen(user: args);
          }
          return const LoginScreen();
        },
      },
    );
  }
}