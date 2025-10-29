//
// LaunchAtLoginService.swift
// MenuPingSwift
//
// Service pour gérer le lancement automatique de l'application à l'ouverture de session macOS.
// Utilise ServiceManagement.SMAppService (macOS 13+)
//

import Foundation
import ServiceManagement

/// Service gérant le lancement automatique à l'ouverture de session
@MainActor
final class LaunchAtLoginService: @unchecked Sendable {
    
    /// Instance singleton
    static let shared = LaunchAtLoginService()
    
    private init() {}
    
    /// Vérifie si l'application est configurée pour se lancer à l'ouverture de session
    var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }
    
    /// Active ou désactive le lancement à l'ouverture de session
    /// - Parameter enabled: true pour activer, false pour désactiver
    /// - Throws: Une erreur si l'opération échoue
    func setEnabled(_ enabled: Bool) throws {
        if enabled {
            // Si déjà activé, ne rien faire
            if SMAppService.mainApp.status == .enabled {
                return
            }
            
            // Tenter d'enregistrer l'app pour le lancement automatique
            try SMAppService.mainApp.register()
        } else {
            // Si déjà désactivé, ne rien faire
            if SMAppService.mainApp.status == .notRegistered {
                return
            }
            
            // Tenter de désenregistrer l'app
            try SMAppService.mainApp.unregister()
        }
    }
    
    /// Toggle l'état du lancement à l'ouverture de session
    /// - Throws: Une erreur si l'opération échoue
    func toggle() throws {
        try setEnabled(!isEnabled)
    }
    
    /// Retourne une description lisible du statut actuel
    var statusDescription: String {
        switch SMAppService.mainApp.status {
        case .enabled:
            return "Activé"
        case .notRegistered:
            return "Désactivé"
        case .notFound:
            return "Non trouvé"
        case .requiresApproval:
            return "Requiert l'approbation de l'utilisateur"
        @unknown default:
            return "Statut inconnu"
        }
    }
}
