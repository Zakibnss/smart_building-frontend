import 'package:flutter/material.dart'; // ← AJOUT IMPÉRATIF

class ServiceModel {
  final int id;
  final int residentId;
  final int? agentServiceId;
  final String type;
  final String description;
  final DateTime? dateSouhaitee;
  final String? heureSouhaitee;
  final String statut;
  final DateTime dateDemande;
  final DateTime? dateIntervention;
  final String? priorite;
  final String? agentNom;
  final String? commentaire;

  ServiceModel({
    required this.id,
    required this.residentId,
    this.agentServiceId,
    required this.type,
    required this.description,
    this.dateSouhaitee,
    this.heureSouhaitee,
    required this.statut,
    required this.dateDemande,
    this.dateIntervention,
    this.priorite,
    this.agentNom,
    this.commentaire,
  });

  // Constructeur depuis JSON
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      residentId: json['resident_id'] ?? 0,
      agentServiceId: json['agent_service_id'],
      type: json['type_service'] ?? json['type'] ?? '',
      description: json['description'] ?? '',
      dateSouhaitee: json['date_souhaitee'] != null 
          ? DateTime.tryParse(json['date_souhaitee']) 
          : null,
      heureSouhaitee: json['heure_souhaitee'],
      statut: json['statut'] ?? 'en_attente',
      dateDemande: DateTime.parse(json['date_demande'] ?? DateTime.now().toIso8601String()),
      dateIntervention: json['date_intervention'] != null 
          ? DateTime.tryParse(json['date_intervention']) 
          : null,
      priorite: json['priorite'] ?? 'normale',
      agentNom: json['agent_nom'],
      commentaire: json['commentaire'],
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resident_id': residentId,
      'agent_service_id': agentServiceId,
      'type_service': type,
      'description': description,
      'date_souhaitee': dateSouhaitee?.toIso8601String(),
      'heure_souhaitee': heureSouhaitee,
      'statut': statut,
      'date_demande': dateDemande.toIso8601String(),
      'date_intervention': dateIntervention?.toIso8601String(),
      'priorite': priorite,
      'agent_nom': agentNom,
      'commentaire': commentaire,
    };
  }

  // Obtenir le libellé du statut en français
  String getStatutLabel() {
    switch (statut) {
      case 'en_attente':
        return 'En attente';
      case 'assigne':
        return 'Assigné';
      case 'en_cours':
        return 'En cours';
      case 'termine':
        return 'Terminé';
      case 'annule':
        return 'Annulé';
      default:
        return statut;
    }
  }

  // Obtenir la couleur du statut
  Color getStatutColor() {
    switch (statut) {
      case 'en_attente':
        return const Color(0xFFFF9800); // Orange
      case 'assigne':
        return const Color(0xFF2196F3); // Bleu
      case 'en_cours':
        return const Color(0xFF4CAF50); // Vert
      case 'termine':
        return const Color(0xFF9E9E9E); // Gris
      case 'annule':
        return const Color(0xFFF44336); // Rouge
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  // Icône du service
  IconData getServiceIcon() {
    switch (type.toLowerCase()) {
      case 'réparation':
      case 'reparation':
        return Icons.build;
      case 'plomberie':
        return Icons.plumbing;
      case 'nettoyage':
        return Icons.cleaning_services;
      case 'gardien':
        return Icons.local_florist;
      case 'sécurité':
      case 'securite':
        return Icons.security;
      case 'maintenance':
        return Icons.electrical_services;
      default:
        return Icons.build;
    }
  }

  // Vérifier si le service peut être annulé
  bool canCancel() {
    return statut == 'en_attente';
  }
}

// Extension pour les listes de services
extension ServiceModelList on List<ServiceModel> {
  List<ServiceModel> filterByStatus(String status) {
    return where((s) => s.statut == status).toList();
  }

  List<ServiceModel> get enAttente => filterByStatus('en_attente');
  List<ServiceModel> get enCours => filterByStatus('en_cours');
  List<ServiceModel> get termines => filterByStatus('termine');
  
  Map<String, int> getStats() {
    return {
      'total': length,
      'en_attente': enAttente.length,
      'en_cours': enCours.length,
      'termine': termines.length,
    };
  }
}