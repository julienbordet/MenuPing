//
// MenuPingSwiftApp.swift
// MenuPingSwift
//
// Point d'entrée principal de l'application.
// Configure la barre de menus avec MenuBarExtra et la fenêtre de préférences.
//

import SwiftUI

@main
struct MenuPingSwiftApp: App {
    @StateObject private var viewModel = AppViewModel()
    
    var body: some Scene {
        // Menu bar item
        MenuBarExtra {
            MenuView(viewModel: viewModel)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: viewModel.isError ? "wifi.exclamationmark" : "wifi")
                if let latency = viewModel.latency {
                    Text(String(format: "%.1f", latency))
                } else {
                    Text("—")
                }
            }
        }
        
        // Preferences window
        Window("Preferences", id: "preferences") {
            PreferencesView(viewModel: viewModel)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}

