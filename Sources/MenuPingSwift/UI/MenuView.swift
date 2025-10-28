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
            if let latency = viewModel.latency {
                Text("\("menu.latency".localized()) \(String(format: "%.0f", latency)) \("menu.latency.ms".localized())")
                    .padding(.horizontal, 12)
            } else {
                Text("\("menu.latency".localized()) —")
                    .padding(.horizontal, 12)
            }
            
            Divider()
            
            // Launch at startup toggle
            Toggle("menu.launch_at_startup".localized(), isOn: Binding(
                get: { viewModel.isLaunchAtLoginEnabled },
                set: { _ in viewModel.toggleLaunchAtLogin() }
            ))
                .toggleStyle(.checkbox)
                .padding(.horizontal, 12)
            
            // Settings button
            Button("menu.settings".localized()) {
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
            Button("menu.quit".localized()) {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
        .padding(.vertical, 4)
    }
}

