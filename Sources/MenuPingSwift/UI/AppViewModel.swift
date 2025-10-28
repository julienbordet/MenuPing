//
// AppViewModel.swift
// MenuPingSwift
//
// ViewModel principal de l'application, gérant l'état du ping,
// les paramètres, et le service de ping continu.
//

import SwiftUI

/// Main view model managing application state
@MainActor
class AppViewModel: ObservableObject {
    
    /// Current ping latency in milliseconds (nil when no ping has been performed)
    @Published var latency: Double?
    
    /// Whether the last ping failed
    @Published var isError: Bool = false
    
    /// Application settings
    @Published var settings: Settings = Settings()
    
    /// Whether the preferences window is shown
    @Published var showingPreferences: Bool = false
    
    /// Continuous ping service
    private let pingService = ContinuousPingService()
    
    init() {
        setupPingService()
        startPinging()
    }
    
    /// Setup ping service callbacks
    private func setupPingService() {
        pingService.onLatencyUpdate = { [weak self] latency in
            guard let self = self else { return }
            self.latency = latency
            self.isError = false
        }
        
        pingService.onFailure = { [weak self] in
            guard let self = self else { return }
            self.latency = nil
            self.isError = true
        }
    }
    
    /// Start continuous ping
    func startPinging() {
        pingService.startPinging(host: settings.host)
    }
    
    /// Stop continuous ping
    func stopPinging() {
        pingService.stopPinging()
    }
    
    /// Update the ping interval
    func updateInterval(_ newInterval: Double) {
        settings.interval = newInterval
        // Note: Interval is not used with continuous ping
        // Each ping result arrives as soon as it's ready
    }
    
    /// Update the ping host
    func updateHost(_ newHost: String) {
        settings.host = newHost
        // Restart ping with new host
        startPinging()
    }
    
    nonisolated deinit {
        Task { @MainActor [weak pingService] in
            pingService?.stopPinging()
        }
    }
}

