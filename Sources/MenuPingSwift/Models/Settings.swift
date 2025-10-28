//
// Settings.swift
// MenuPingSwift
//
// Structure de données pour les paramètres de configuration de l'application.
// Contient l'hôte cible et l'intervalle de ping.
// Utilise le framework @Observable moderne (macOS 15+)
// Les paramètres sont automatiquement persistés dans UserDefaults.
//

import Foundation
import Observation

/// Configuration settings for the ping application
/// Note: @Observable provides its own thread-safety, Sendable not needed
@Observable
final class Settings {
    
    // MARK: - UserDefaults Keys
    
    private enum Keys {
        static let host = "com.menuping.settings.host"
        static let interval = "com.menuping.settings.interval"
    }
    
    // MARK: - Default Values
    
    private enum Defaults {
        static let host = "www.google.com"
        static let interval = 1.0
    }
    
    // MARK: - Private Storage
    
    private let userDefaults: UserDefaults
    
    // MARK: - Public Properties
    
    /// The host to ping (default: www.google.com)
    /// Automatically persisted to UserDefaults
    var host: String {
        get {
            userDefaults.string(forKey: Keys.host) ?? Defaults.host
        }
        set {
            userDefaults.set(newValue, forKey: Keys.host)
        }
    }
    
    /// The interval between pings in seconds (default: 1.0)
    /// Automatically persisted to UserDefaults
    var interval: Double {
        get {
            let value = userDefaults.double(forKey: Keys.interval)
            // Si la valeur est 0, c'est qu'elle n'existe pas encore (UserDefaults retourne 0 par défaut)
            return value == 0.0 ? Defaults.interval : value
        }
        set {
            userDefaults.set(newValue, forKey: Keys.interval)
        }
    }
    
    // MARK: - Initialization
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        
        // Enregistrer les valeurs par défaut si c'est la première exécution
        registerDefaultsIfNeeded()
    }
    
    // MARK: - Private Methods
    
    /// Enregistre les valeurs par défaut dans UserDefaults si elles n'existent pas
    private func registerDefaultsIfNeeded() {
        // Vérifier si c'est la première exécution
        let firstLaunchKey = "com.menuping.firstLaunch"
        
        if !userDefaults.bool(forKey: firstLaunchKey) {
            // Première exécution : enregistrer les valeurs par défaut
            userDefaults.set(Defaults.host, forKey: Keys.host)
            userDefaults.set(Defaults.interval, forKey: Keys.interval)
            userDefaults.set(true, forKey: firstLaunchKey)
        }
    }
    
    /// Réinitialise tous les paramètres à leurs valeurs par défaut
    func resetToDefaults() {
        host = Defaults.host
        interval = Defaults.interval
    }
}

