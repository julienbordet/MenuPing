//
// MenuView.swift
// MenuPingSwift
//
// Vue affichée dans le menu déroulant de la barre de menus.
// Contient le statut du ping, un bouton de préférences, et un bouton Quitter.
// Utilise @Observable moderne (macOS 15+)
//

import SwiftUI
import AppKit

/// View displayed in the menu bar dropdown
struct MenuView: View {
    var viewModel: AppViewModel
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Status section
            HStack {
                Text("Host:")
                    .foregroundColor(.secondary)
                Text(viewModel.settings.host)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            
            HStack {
                Text("Latency:")
                    .foregroundColor(.secondary)
                if let latency = viewModel.latency {
                    Text(String(format: "%.0f ms", latency))
                        .fontWeight(.medium)
                } else {
                    Text("—")
                        .fontWeight(.medium)
                }
            }
            .padding(.horizontal, 12)
            
            Divider()
            
            // Settings button
            Button("Settings...") {
                openWindow(id: "settings")
                // Activate app and bring window to front
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    // Find and bring the settings window to front
                    if let window = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "settings" }) {
                        window.makeKeyAndOrderFront(nil)
                        window.orderFrontRegardless()
                    }
                }
            }
            .keyboardShortcut(",", modifiers: .command)
            
            Divider()
            
            // Quit button
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
        .padding(.vertical, 4)
    }
}

