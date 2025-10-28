//
// MenuView.swift
// MenuPingSwift
//
// Vue affichée dans le menu déroulant de la barre de menus.
// Contient le statut du ping, un bouton de préférences, et un bouton Quitter.
//

import SwiftUI

/// View displayed in the menu bar dropdown
struct MenuView: View {
    @ObservedObject var viewModel: AppViewModel
    
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
                    Text(String(format: "%.1f ms", latency))
                        .fontWeight(.medium)
                } else {
                    Text("—")
                        .fontWeight(.medium)
                }
            }
            .padding(.horizontal, 12)
            
            Divider()
            
            // Preferences button
            Button("Preferences...") {
                viewModel.showingPreferences = true
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

