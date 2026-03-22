import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/resident.dart';
import '../models/reclamation.dart';
import '../models/colis.dart';
import '../models/notification.dart';
import '../models/parking.dart';
import '../models/service_model.dart';

class ApiService {
  // Pour Chrome (localhost)
  static const String baseUrl =
      'http://localhost/smart-residence/smart_building-backend/backend/api';

  // Pour Android emulator (décommentez si besoin)
  // static const String baseUrl = 'http://10.0.2.2/smart-residence/backend/api';

  // ==================== AUTHENTIFICATION ====================

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔵 Tentative de connexion...');
      print('Email: $email');
      print('Password: $password');

      var body = json.encode({
        'email': email,
        'password': password,
      });

      print('📦 Corps de la requête: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      print('📥 Réponse status: ${response.statusCode}');
      print('📥 Réponse brute: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          print('✅ Réponse JSON: $jsonResponse');

          if (jsonResponse['success'] == true) {
            jsonResponse['user'] = User.fromJson(jsonResponse['user']);
          }

          return jsonResponse;
        } catch (e) {
          print('❌ Erreur parsing JSON: $e');
          return {
            'success': false,
            'message': 'Erreur de parsing: $e\nRéponse: ${response.body}'
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Erreur serveur: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  // ==================== DÉCONNEXION ====================

  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Erreur lors de la déconnexion'};
    } catch (e) {
      print('❌ Erreur déconnexion: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // ==================== ADMINISTRATION - STATISTIQUES ====================

  static Future<Map<String, dynamic>> getAdminStats() async {
    try {
      print('📊 Récupération des statistiques...');
      final response = await http.get(
        Uri.parse('$baseUrl/admin/stats.php'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse brute: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('✅ Réponse JSON: $jsonResponse');
        
        if (jsonResponse.containsKey('success') && jsonResponse['success'] == true) {
          return jsonResponse;
        } else {
          return {'success': false, 'message': 'Structure de données invalide'};
        }
      }
      return {'success': false, 'message': 'Erreur chargement stats'};
    } catch (e) {
      print('❌ Erreur stats admin: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // ==================== ACTIVITÉS RÉCENTES ====================

  static Future<Map<String, dynamic>> getRecentActivities() async {
    try {
      print('📊 Récupération des activités récentes...');
      final response = await http.get(
        Uri.parse('$baseUrl/admin/recent_activities.php'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'activities': []};
    } catch (e) {
      print('❌ Erreur activités récentes: $e');
      return {'success': false, 'activities': []};
    }
  }

  // ==================== MÉTHODES POUR RÉSIDENT ====================

  // ----- PROFIL -----
  static Future<Map<String, dynamic>> getProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resident/profile.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Erreur chargement profil'};
    } catch (e) {
      print('❌ Erreur profil: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<bool> updateProfile(int userId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/resident/profile.php?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur mise à jour profil: $e');
      return false;
    }
  }

  // ----- RÉCLAMATIONS -----
  static Future<Map<String, dynamic>> getReclamationsByUser(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resident/reclamations.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'reclamations': []};
    } catch (e) {
      print('❌ Erreur réclamations: $e');
      return {'success': false, 'reclamations': []};
    }
  }

  static Future<Map<String, dynamic>> getReclamationDetail(int reclamationId, int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resident/reclamations.php?id=$reclamationId&user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false};
    } catch (e) {
      print('❌ Erreur détail réclamation: $e');
      return {'success': false};
    }
  }

  static Future<bool> createReclamation(Map<String, dynamic> reclamationData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resident/reclamations.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reclamationData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur création réclamation: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getReclamationStats(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resident/reclamation_stats.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false};
    } catch (e) {
      print('❌ Erreur stats réclamations: $e');
      return {'success': false};
    }
  }

  static Future<bool> submitReclamationFeedback(Map<String, dynamic> feedbackData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resident/reclamation_feedback.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(feedbackData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur feedback réclamation: $e');
      return false;
    }
  }

  // ----- SERVICES -----
  static Future<Map<String, dynamic>> getServices(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resident/services.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'services': []};
    } catch (e) {
      print('❌ Erreur services: $e');
      return {'success': false, 'services': []};
    }
  }

  static Future<Map<String, dynamic>> getServiceDetail(int serviceId, int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resident/services.php?id=$serviceId&user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false};
    } catch (e) {
      print('❌ Erreur détail service: $e');
      return {'success': false};
    }
  }

  static Future<bool> createServiceRequest(Map<String, dynamic> serviceData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resident/services.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(serviceData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur création service: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getServiceHistory(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resident/service_history.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'services': []};
    } catch (e) {
      print('❌ Erreur historique services: $e');
      return {'success': false, 'services': []};
    }
  }

  static Future<bool> cancelServiceRequest(int serviceId, int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/resident/services.php?id=$serviceId&user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur annulation service: $e');
      return false;
    }
  }

  // ----- COLIS -----
  static Future<Map<String, dynamic>> getColisByUser(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resident/colis.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'colis': []};
    } catch (e) {
      print('❌ Erreur colis: $e');
      return {'success': false, 'colis': []};
    }
  }

  static Future<Map<String, dynamic>> getColisDetail(int colisId, int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resident/colis.php?id=$colisId&user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false};
    } catch (e) {
      print('❌ Erreur détail colis: $e');
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> markColisAsReceivedResident(int colisId, int userId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/resident/colis.php?id=$colisId&user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'statut': 'remis'}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Erreur serveur'};
    } catch (e) {
      print('❌ Erreur mise à jour colis: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // ----- PARKING POUR RÉSIDENTS -----
  static Future<Map<String, dynamic>> getParkingInfo(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resident/parking_resident.php?action=myplace&user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false};
    } catch (e) {
      print('❌ Erreur parking info: $e');
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> getAvailableParkingPlaces() async {
    try {
      final userId = await _getCurrentUserId();
      print('🔍 getAvailableParkingPlaces - user_id: $userId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/resident/parking_resident.php?action=available&user_id=$userId'),
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'places': []};
    } catch (e) {
      print('❌ Erreur places disponibles: $e');
      return {'success': false, 'places': []};
    }
  }

  static Future<int> _getCurrentUserId() async {
    // À implémenter avec SharedPreferences
    return 6; // ID par défaut pour les tests
  }

  static Future<Map<String, dynamic>> getParkingStatsResident() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resident/parking_resident.php'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false};
    } catch (e) {
      print('❌ Erreur stats parking résident: $e');
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> reserveParkingPlace(int userId, int parkingId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resident/parking_resident.php?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'parking_id': parkingId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Erreur serveur'};
    } catch (e) {
      print('❌ Erreur réservation: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> libererParkingPlace(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/resident/parking_resident.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Erreur serveur'};
    } catch (e) {
      print('❌ Erreur libération: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // ----- SMART MAILBOX -----
  static Future<Map<String, dynamic>> getSmartMailboxStatusResident(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resident/smartmailbox.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false};
    } catch (e) {
      print('❌ Erreur smart mailbox: $e');
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> openSmartMailbox(int userId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/resident/smartmailbox.php?user_id=$userId&action=ouvrir'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false};
    } catch (e) {
      print('❌ Erreur ouverture mailbox: $e');
      return {'success': false};
    }
  }

  static Future<bool> retrieveColisFromMailbox(int userId, int colisId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/resident/smartmailbox.php?user_id=$userId&action=recuperer&colis_id=$colisId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur récupération colis: $e');
      return false;
    }
  }

  // ----- NOTIFICATIONS POUR RÉSIDENT -----
  static Future<Map<String, dynamic>> getNotificationsResident(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resident/notifications.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'notifications': [], 'non_lues': 0};
    } catch (e) {
      print('❌ Erreur notifications: $e');
      return {'success': false, 'notifications': [], 'non_lues': 0};
    }
  }

  static Future<bool> markNotificationAsReadResident(int notificationId, int userId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/resident/notifications.php?id=$notificationId&user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur marquage notification: $e');
      return false;
    }
  }

  static Future<bool> markAllNotificationsAsRead(int userId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/resident/notifications.php?all=true&user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur marquage toutes notifications: $e');
      return false;
    }
  }

  // ==================== MÉTHODES POUR AGENT DE SÉCURITÉ ====================

  // ----- COLIS -----
  static Future<Map<String, dynamic>> enregistrerColis(Map<String, dynamic> colisData) async {
    try {
      print('📤 Enregistrement colis: $colisData');
      
      final response = await http.post(
        Uri.parse('$baseUrl/agent/colis.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(colisData),
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Erreur serveur'};
    } catch (e) {
      print('❌ Erreur enregistrement colis: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getDerniersColis() async {
    try {
      print('📤 Récupération derniers colis');
      
      final response = await http.get(
        Uri.parse('$baseUrl/agent/colis.php?action=recent'),
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'colis': []};
    } catch (e) {
      print('❌ Erreur récupération colis: $e');
      return {'success': false, 'colis': []};
    }
  }

  static Future<Map<String, dynamic>> marquerColisRecupere(int colisId) async {
    try {
      print('📤 Marquage colis $colisId comme récupéré');
      
      final response = await http.put(
        Uri.parse('$baseUrl/agent/colis.php?id=$colisId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'statut': 'recupere'}),
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Erreur serveur'};
    } catch (e) {
      print('❌ Erreur marquage colis: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // ----- RECHERCHE RÉSIDENTS -----
  static Future<Map<String, dynamic>> rechercherResidentParNom(String nom) async {
    try {
      print('📤 Recherche résident par nom: $nom');
      
      final response = await http.get(
        Uri.parse('$baseUrl/agent/recherche_resident.php?nom=${Uri.encodeComponent(nom)}'),
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'residents': []};
    } catch (e) {
      print('❌ Erreur recherche résident: $e');
      return {'success': false, 'residents': []};
    }
  }

  static Future<Map<String, dynamic>> rechercherResidentParAppartement(String appartement, String batiment) async {
    try {
      print('📤 Recherche résident par app: $appartement, bât: $batiment');
      
      final response = await http.get(
        Uri.parse('$baseUrl/agent/recherche_resident.php?appartement=${Uri.encodeComponent(appartement)}&batiment=${Uri.encodeComponent(batiment)}'),
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'residents': []};
    } catch (e) {
      print('❌ Erreur recherche résident: $e');
      return {'success': false, 'residents': []};
    }
  }

  static Future<Map<String, dynamic>> getTousResidents() async {
    try {
      print('📤 Récupération tous les résidents');
      
      final response = await http.get(
        Uri.parse('$baseUrl/agent/recherche_resident.php?action=all'),
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'residents': []};
    } catch (e) {
      print('❌ Erreur récupération résidents: $e');
      return {'success': false, 'residents': []};
    }
  }

  // ----- PARKING POUR AGENT -----
  static Future<Map<String, dynamic>> getParkingResidents() async {
    try {
      print('📤 Récupération parking résidents');
      
      final response = await http.get(
        Uri.parse('$baseUrl/agent/parking.php?type=resident'),
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'places': []};
    } catch (e) {
      print('❌ Erreur parking résidents: $e');
      return {'success': false, 'places': []};
    }
  }

  static Future<Map<String, dynamic>> getParkingVisiteurs() async {
    try {
      print('📤 Récupération parking visiteurs');
      
      final response = await http.get(
        Uri.parse('$baseUrl/agent/parking.php?type=visiteur'),
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'places': []};
    } catch (e) {
      print('❌ Erreur parking visiteurs: $e');
      return {'success': false, 'places': []};
    }
  }

  static Future<Map<String, dynamic>> getParkingStatsAgent() async {
    try {
      print('📤 Récupération stats parking agent');
      
      final response = await http.get(
        Uri.parse('$baseUrl/agent/parking.php?action=stats'),
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false};
    } catch (e) {
      print('❌ Erreur stats parking agent: $e');
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> reserverPlaceVisiteur(
    int parkingId, 
    String nomVisiteur, 
    String immatriculation
  ) async {
    try {
      print('📤 Réservation place visiteur: $parkingId pour $nomVisiteur');
      
      final url = Uri.parse('$baseUrl/agent/parking.php');
      print('📤 URL: $url');
      
      final body = json.encode({
        'action': 'reserver',
        'parking_id': parkingId,
        'nom_visiteur': nomVisiteur,
        'immatriculation': immatriculation,
      });
      print('📤 Body: $body');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse brute: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty) {
          print('❌ Réponse vide');
          return {
            'success': false, 
            'message': 'Le serveur a renvoyé une réponse vide'
          };
        }
        
        try {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          print('✅ Réponse JSON: $jsonResponse');
          return jsonResponse;
        } catch (e) {
          print('❌ Erreur parsing JSON: $e');
          return {
            'success': false, 
            'message': 'Erreur de parsing: $e\nRéponse: ${response.body}'
          };
        }
      } else {
        return {
          'success': false, 
          'message': 'Erreur HTTP ${response.statusCode}'
        };
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': 'Exception: $e'};
    }
  }

  static Future<Map<String, dynamic>> libererPlaceVisiteur(int parkingId) async {
    try {
      print('📤 Libération place visiteur: $parkingId');
      
      final response = await http.put(
        Uri.parse('$baseUrl/agent/parking.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'liberer',
          'parking_id': parkingId,
        }),
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Erreur serveur'};
    } catch (e) {
      print('❌ Erreur libération: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> verifierPlaceResident(int parkingId) async {
    try {
      print('📤 Vérification place résident: $parkingId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/agent/parking.php?action=verifier&parking_id=$parkingId'),
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false};
    } catch (e) {
      print('❌ Erreur vérification: $e');
      return {'success': false};
    }
  }

  // ----- ACCÈS VISITEUR -----
  static Future<Map<String, dynamic>> genererAccesVisiteur(Map<String, dynamic> accesData) async {
    try {
      print('📤 Génération accès visiteur: $accesData');
      
      final response = await http.post(
        Uri.parse('$baseUrl/agent/acces_visiteur.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(accesData),
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> result = json.decode(response.body);
        // Convertir code_acces en String si nécessaire
        if (result['code_acces'] is int) {
          result['code_acces'] = result['code_acces'].toString();
        }
        return result;
      }
      return {'success': false, 'message': 'Erreur serveur'};
    } catch (e) {
      print('❌ Erreur génération accès: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getAccesVisiteurEnCours() async {
    try {
      print('📤 Récupération accès visiteurs en cours');
      
      final response = await http.get(
        Uri.parse('$baseUrl/agent/acces_visiteur.php'),
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'acces': []};
    } catch (e) {
      print('❌ Erreur récupération accès: $e');
      return {'success': false, 'acces': []};
    }
  }

  static Future<Map<String, dynamic>> terminerAccesVisiteur(int accesId) async {
    try {
      print('📤 Terminaison accès visiteur: $accesId');
      
      final response = await http.put(
        Uri.parse('$baseUrl/agent/acces_visiteur.php?id=$accesId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'statut': 'termine'}),
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Erreur serveur'};
    } catch (e) {
      print('❌ Erreur terminaison accès: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // ----- VÉRIFICATION CODE ACCÈS (pour scanner) -----
  static Future<Map<String, dynamic>> verifierCodeAcces(String code) async {
    try {
      print('🔍 Vérification code accès: $code');
      
      final response = await http.get(
        Uri.parse('$baseUrl/agent/verifier_code.php?code=$code'),
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'valide': false, 'message': 'Erreur serveur'};
    } catch (e) {
      print('❌ Erreur vérification code: $e');
      return {'success': false, 'valide': false, 'message': e.toString()};
    }
  }

  // ----- NOTIFICATIONS POUR AGENT -----
  static Future<Map<String, dynamic>> getNotificationsAgent(int agentId) async {
    try {
      print('📤 Récupération notifications agent: $agentId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/agent/notifications.php?agent_id=$agentId'),
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'notifications': [], 'non_lues': 0};
    } catch (e) {
      print('❌ Erreur notifications agent: $e');
      return {'success': false, 'notifications': [], 'non_lues': 0};
    }
  }

  static Future<bool> marquerNotificationLueAgent(int notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/agent/notifications.php?id=$notificationId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur marquage notification: $e');
      return false;
    }
  }

  // ==================== GESTION DES RÉSIDENTS (Admin) ====================

  static Future<List<Resident>> getResidents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/residents.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          List<Resident> residents = [];
          for (var item in data['residents']) {
            residents.add(Resident.fromJson(item));
          }
          return residents;
        }
      }
      return [];
    } catch (e) {
      print('❌ Erreur chargement résidents: $e');
      return [];
    }
  }

  static Future<bool> addResident(Map<String, dynamic> residentData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/residents.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(residentData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur ajout résident: $e');
      return false;
    }
  }

  static Future<bool> updateResident(int id, Map<String, dynamic> residentData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/residents.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(residentData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur modification résident: $e');
      return false;
    }
  }

  static Future<bool> deleteResident(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/residents.php?id=$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur suppression résident: $e');
      return false;
    }
  }

  // ==================== GESTION DES AGENTS (Admin) ====================

  static Future<List<User>> getSecurityAgents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/security_agents.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          List<User> agents = [];
          for (var item in data['agents']) {
            agents.add(User.fromJson(item));
          }
          return agents;
        }
      }
      return [];
    } catch (e) {
      print('❌ Erreur chargement agents sécurité: $e');
      return [];
    }
  }

  static Future<List<User>> getServiceAgents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/service_agents.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          List<User> agents = [];
          for (var item in data['agents']) {
            agents.add(User.fromJson(item));
          }
          return agents;
        }
      }
      return [];
    } catch (e) {
      print('❌ Erreur chargement agents service: $e');
      return [];
    }
  }

  static Future<bool> addSecurityAgent(Map<String, dynamic> agentData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/security_agents.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(agentData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur ajout agent sécurité: $e');
      return false;
    }
  }

  static Future<bool> updateSecurityAgent(int id, Map<String, dynamic> agentData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/security_agents.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(agentData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur modification agent sécurité: $e');
      return false;
    }
  }

  static Future<bool> deleteSecurityAgent(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/security_agents.php?id=$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur suppression agent sécurité: $e');
      return false;
    }
  }

  static Future<bool> addServiceAgent(Map<String, dynamic> agentData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/service_agents.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(agentData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur ajout agent service: $e');
      return false;
    }
  }

  static Future<bool> updateServiceAgent(int id, Map<String, dynamic> agentData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/service_agents.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(agentData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur modification agent service: $e');
      return false;
    }
  }

  static Future<bool> deleteServiceAgent(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/service_agents.php?id=$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur suppression agent service: $e');
      return false;
    }
  }

  // ==================== GESTION DES TECHNICIENS ====================

  static Future<List<User>> getTechnicians() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/technicians.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          List<User> technicians = [];
          for (var item in data['technicians']) {
            technicians.add(User.fromJson(item));
          }
          return technicians;
        }
      }
      return [];
    } catch (e) {
      print('❌ Erreur chargement techniciens: $e');
      return [];
    }
  }

  static Future<bool> addTechnician(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/technicians.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur ajout technicien: $e');
      return false;
    }
  }

  static Future<bool> updateTechnician(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/technicians.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur modification technicien: $e');
      return false;
    }
  }

  static Future<bool> deleteTechnician(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/technicians.php?id=$id'),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur suppression technicien: $e');
      return false;
    }
  }

  // ==================== STATISTIQUES TECHNICIENS ====================
  
  static Future<Map<String, dynamic>> getTechniciansStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/technicians_stats.php'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Erreur chargement stats'};
    } catch (e) {
      print('❌ Erreur stats techniciens: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // ==================== PARKING ADMIN ====================

  static Future<Map<String, dynamic>> getParkingConfig() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/parking_config.php'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'places': [], 'residents_sans_parking': []};
    } catch (e) {
      print('❌ Erreur config parking: $e');
      return {'success': false, 'places': [], 'residents_sans_parking': []};
    }
  }

  static Future<Map<String, dynamic>> getParkingStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/parking_config.php?action=stats'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false};
    } catch (e) {
      print('❌ Erreur stats parking: $e');
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> getParkingHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/parking_config.php?action=history'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'history': []};
    } catch (e) {
      print('❌ Erreur historique parking: $e');
      return {'success': false, 'history': []};
    }
  }

  static Future<Map<String, dynamic>> configureParking(int placesResident, int placesVisiteur) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/parking_config.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'configure',
          'places_resident': placesResident,
          'places_visiteur': placesVisiteur,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Erreur serveur'};
    } catch (e) {
      print('❌ Erreur configuration: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> assignParkingPlace(int residentId, int parkingId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/parking_config.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'assign',
          'resident_id': residentId,
          'parking_id': parkingId,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Erreur serveur'};
    } catch (e) {
      print('❌ Erreur assignation: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> libererParkingPlaceAdmin(int parkingId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/parking_config.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'liberer',
          'parking_id': parkingId,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Erreur serveur'};
    } catch (e) {
      print('❌ Erreur libération: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // ==================== NOTIFICATIONS (Admin) ====================

  static Future<List<Notification>> getNotifications(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          List<Notification> notifications = [];
          for (var item in data['notifications']) {
            notifications.add(Notification.fromJson(item));
          }
          return notifications;
        }
      }
      return [];
    } catch (e) {
      print('❌ Erreur chargement notifications: $e');
      return [];
    }
  }

  static Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications.php?id=$notificationId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'est_lu': true}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur mise à jour notification: $e');
      return false;
    }
  }

  static Future<bool> sendNotification(int userId, String titre, String contenu, String type) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'utilisateur_id': userId,
          'titre': titre,
          'contenu': contenu,
          'type': type,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur envoi notification: $e');
      return false;
    }
  }

  // ==================== SMART MAILBOX (Admin) ====================

  static Future<Map<String, dynamic>> getSmartMailboxStatus(int residentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/smartmailbox.php?resident_id=$residentId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false};
    } catch (e) {
      print('❌ Erreur chargement smart mailbox: $e');
      return {'success': false};
    }
  }

  static Future<bool> notifyColisDepot(int residentId, int colisId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/smartmailbox.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'resident_id': residentId,
          'colis_id': colisId,
          'action': 'depot',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur notification dépôt: $e');
      return false;
    }
  }
  static Future<Map<String, dynamic>> getReclamations() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/reclamations.php'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {'success': false, 'reclamations': []};
  } catch (e) {
    print('❌ Erreur réclamations: $e');
    return {'success': false, 'reclamations': []};
  }
}

static Future<Map<String, dynamic>> updateReclamationStatus(int reclamationId, String statut) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/reclamations.php?id=$reclamationId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'statut': statut}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {'success': false, 'message': 'Erreur serveur'};
  } catch (e) {
    print('❌ Erreur mise à jour statut: $e');
    return {'success': false, 'message': e.toString()};
  }
}

static Future<Map<String, dynamic>> assignerReclamation(int reclamationId, int agentId) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/reclamations.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'action': 'assign',
        'reclamation_id': reclamationId,
        'agent_id': agentId,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {'success': false, 'message': 'Erreur serveur'};
  } catch (e) {
    print('❌ Erreur assignation: $e');
    return {'success': false, 'message': e.toString()};
  }
}

  // ==================== SERVICES & MISSIONS (Admin) ====================

  static Future<List<dynamic>> getServiceRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['services'] ?? [];
      }
      return [];
    } catch (e) {
      print('❌ Erreur chargement services: $e');
      return [];
    }
  }

  static Future<bool> assignMission(int serviceId, int agentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/missions.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': serviceId,
          'agent_id': agentId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur assignation mission: $e');
      return false;
    }
  }

  static Future<bool> acceptMission(int missionId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/missions.php?id=$missionId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': 'accepter'}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur acceptation mission: $e');
      return false;
    }
  }

  static Future<bool> completeMission(int missionId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/missions.php?id=$missionId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': 'terminer'}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur terminaison mission: $e');
      return false;
    }
  }
}