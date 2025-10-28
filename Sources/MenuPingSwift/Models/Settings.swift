//
// Settings.swift
// MenuPingSwift
//
// Structure de données pour les paramètres de configuration de l'application.
// Contient l'hôte cible et l'intervalle de ping.
// Utilise le framework @Observable moderne (macOS 15+)
//

import Foundation
import Observation

/// Configuration settings for the ping application
/// Note: @Observable provides its own thread-safety, Sendable not needed
@Observable
final class Settings {
    /// The host to ping (default: www.google.com)
    var host: String = "www.google.com"
    
    /// The interval between pings in seconds (default: 1.0)
    var interval: Double = 1.0
    
    init(host: String = "www.google.com", interval: Double = 1.0) {
        self.host = host
        self.interval = interval
    }
}

