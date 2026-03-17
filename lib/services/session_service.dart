import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class SessionService {
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';

  // Sauvegarder l'utilisateur après connexion
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, user.id);
    await prefs.setString(_userNameKey, user.nom);
    await prefs.setString(_userEmailKey, user.email);
    await prefs.setString(_userRoleKey, user.role);
  }

  // Récupérer l'ID de l'utilisateur connecté
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // Récupérer l'utilisateur complet
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_userIdKey);
    final nom = prefs.getString(_userNameKey);
    final email = prefs.getString(_userEmailKey);
    final role = prefs.getString(_userRoleKey);

    if (id != null && nom != null && email != null && role != null) {
      return User(
        id: id,
        nom: nom,
        email: email,
        role: role,
        complexId: 1, // Valeur par défaut ou à stocker aussi
      );
    }
    return null;
  }

  // Vérifier si un utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userIdKey);
  }

  // Déconnexion - effacer les données
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}