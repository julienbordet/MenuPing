//
// AppViewModel.swift
// MenuPingSwift
//
// ViewModel principal de l'application, gérant l'état du ping,
// les paramètres, et le service de ping continu.
// Utilise @Observable moderne (macOS 15+)
//

import SwiftUI
import Observation

/// Main view model managing application state
@Observable
@MainActor
final class AppViewModel {
    
    /// Current ping latency in milliseconds (nil when no ping has been performed)
    var latency: Double?
    
    /// Whether the last ping failed
    var isError: Bool = true  // Start as true since latency is nil initially
    
    /// Application settings
    var settings: Settings = Settings()
    
    /// Continuous ping service
    private let pingService = ContinuousPingService()
    
    /// Launch at login service
    private let launchService = LaunchAtLoginService.shared
    
    init() {
        setupPingService()
        startPinging()
    }
    
    /// Setup ping service callbacks with proper MainActor isolation
    private func setupPingService() {
        pingService.minInterval = settings.interval
        pingService.onLatencyUpdate = { @MainActor [weak self] latency in
            guard let self = self else { return }
            self.latency = latency
            self.isError = false  // Explicitly set error to false on success
        }
        
        pingService.onFailure = { @MainActor [weak self] in
            guard let self = self else { return }
            self.latency = nil
            self.isError = true  // Explicitly set error to true on failure
        }
    }
    
    /// Start continuous ping
    func startPinging() {
        pingService.minInterval = settings.interval
        pingService.startPinging(host: settings.host)
    }
    
    /// Stop continuous ping
    func stopPinging() {
        pingService.stopPinging()
    }
    
    /// Update the ping interval
    func updateInterval(_ newInterval: Double) {
        settings.interval = newInterval
        pingService.minInterval = newInterval
    }
    
    /// Update the ping host
    func updateHost(_ newHost: String) {
        settings.host = newHost
        // Restart ping with new host
        startPinging()
    }
    
    /// Check if launch at login is enabled
    var isLaunchAtLoginEnabled: Bool {
        launchService.isEnabled
    }
    
    /// Toggle launch at login
    func toggleLaunchAtLogin() {
        do {
            try launchService.toggle()
        } catch {
            print("Failed to toggle launch at login: \(error)")
        }
    }
    
    // Note: Modern Swift 6 actor isolation handles cleanup automatically
    // The pingService will be properly deallocated
}

