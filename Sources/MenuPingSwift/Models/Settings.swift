//
// Settings.swift
// MenuPingSwift
//
// Structure de données pour les paramètres de configuration de l'application.
// Contient l'hôte cible et l'intervalle de ping.
//

import Foundation

/// Configuration settings for the ping application
struct Settings {
    /// The host to ping (default: www.google.com)
    var host: String = "www.google.com"
    
    /// The interval between pings in seconds (default: 1.0)
    var interval: Double = 1.0
}

