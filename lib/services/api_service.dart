import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/resident.dart';
import '../models/reclamation.dart';
import '../models/colis.dart';
import '../models/notification.dart';
import '../models/parking.dart';

class ApiService {
  // Pour Chrome (localhost)
  static const String baseUrl =
      'http://localhost/smart-residence/smart_building-backend/backend/api';

  // Pour Android emulator (décommentez si besoin)
  // static const String baseUrl = 'http://10.0.2.2/smart-residence/backend/api';

  // ==================== AUTHENTIFICATION ====================

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
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

          // Convertir l'utilisateur en objet User si la connexion est réussie
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
      
      // S'assurer que la réponse a la structure attendue
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
  // ==================== GESTION DES RÉSIDENTS ====================

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

  static Future<bool> updateResident(
      int id, Map<String, dynamic> residentData) async {
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

  // ==================== GESTION DES AGENTS DE SÉCURITÉ ====================

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

  static Future<bool> updateSecurityAgent(
      int id, Map<String, dynamic> agentData) async {
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

  // ==================== GESTION DES AGENTS DE SERVICE ====================

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

  static Future<bool> updateServiceAgent(
      int id, Map<String, dynamic> agentData) async {
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

  // ==================== GESTION DES TECHNICIENS (CONSULTATION SEULE) ====================
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

  // ==================== RÉCLAMATIONS ====================

  static Future<List<Reclamation>> getReclamations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reclamations.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          List<Reclamation> reclamations = [];
          for (var item in data['reclamations']) {
            reclamations.add(Reclamation.fromJson(item));
          }
          return reclamations;
        }
      }
      return [];
    } catch (e) {
      print('❌ Erreur chargement réclamations: $e');
      return [];
    }
  }

  static Future<List<Reclamation>> getReclamationsByResident(
      int residentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reclamations.php?resident_id=$residentId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          List<Reclamation> reclamations = [];
          for (var item in data['reclamations']) {
            reclamations.add(Reclamation.fromJson(item));
          }
          return reclamations;
        }
      }
      return [];
    } catch (e) {
      print('❌ Erreur chargement réclamations résident: $e');
      return [];
    }
  }

  static Future<bool> createReclamation(
      Map<String, dynamic> reclamationData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reclamations.php'),
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

  static Future<bool> updateReclamationStatus(int id, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reclamations.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'statut': status}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur mise à jour réclamation: $e');
      return false;
    }
  }

  // ==================== COLIS ====================

  static Future<List<Colis>> getColis() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/colis.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          List<Colis> colisList = [];
          for (var item in data['colis']) {
            colisList.add(Colis.fromJson(item));
          }
          return colisList;
        }
      }
      return [];
    } catch (e) {
      print('❌ Erreur chargement colis: $e');
      return [];
    }
  }

  static Future<List<Colis>> getColisByResident(int residentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/colis.php?resident_id=$residentId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          List<Colis> colisList = [];
          for (var item in data['colis']) {
            colisList.add(Colis.fromJson(item));
          }
          return colisList;
        }
      }
      return [];
    } catch (e) {
      print('❌ Erreur chargement colis résident: $e');
      return [];
    }
  }

  static Future<bool> createColis(Map<String, dynamic> colisData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/colis.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(colisData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur création colis: $e');
      return false;
    }
  }

  static Future<bool> markColisAsReceived(int colisId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/colis.php?id=$colisId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'statut': 'remis'}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur mise à jour colis: $e');
      return false;
    }
  }

  // ==================== PARKING ====================

  static Future<List<ParkingSpot>> getParkingSpots() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parking.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          List<ParkingSpot> spots = [];
          for (var item in data['parking']) {
            spots.add(ParkingSpot.fromJson(item));
          }
          return spots;
        }
      }
      return [];
    } catch (e) {
      print('❌ Erreur chargement parking: $e');
      return [];
    }
  }

  static Future<bool> updateParkingSpot(
      int id, String statut, int? residentId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/parking.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'statut': statut,
          'resident_id': residentId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Erreur mise à jour parking: $e');
      return false;
    }
  }

  // ==================== NOTIFICATIONS ====================

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

  static Future<bool> sendNotification(
      int userId, String titre, String contenu, String type) async {
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

  // ==================== SMART MAILBOX ====================

  static Future<Map<String, dynamic>> getSmartMailboxStatus(
      int residentId) async {
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

  // ==================== SERVICES & MISSIONS ====================

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