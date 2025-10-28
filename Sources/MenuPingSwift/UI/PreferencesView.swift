//
// PreferencesView.swift
// MenuPingSwift
//
// Vue de configuration permettant de modifier l'hôte cible
// et l'intervalle de ping.
//

import SwiftUI

/// Preferences window view
struct PreferencesView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var hostInput: String
    @State private var intervalInput: String
    
    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
        _hostInput = State(initialValue: viewModel.settings.host)
        _intervalInput = State(initialValue: String(format: "%.1f", viewModel.settings.interval))
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Host", text: $hostInput)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    TextField("Interval (seconds)", text: $intervalInput)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 150)
                    Text("seconds")
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Ping Configuration")
                    .font(.headline)
            }
            
            HStack {
                Spacer()
                
                Button("Cancel") {
                    resetInputs()
                    viewModel.showingPreferences = false
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Apply") {
                    applyChanges()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .frame(width: 400)
    }
    
    /// Reset inputs to current settings
    private func resetInputs() {
        hostInput = viewModel.settings.host
        intervalInput = String(format: "%.1f", viewModel.settings.interval)
    }
    
    /// Apply changes to the view model
    private func applyChanges() {
        // Update host if changed
        let trimmedHost = hostInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedHost.isEmpty && trimmedHost != viewModel.settings.host {
            viewModel.updateHost(trimmedHost)
        }
        
        // Update interval if valid
        if let interval = Double(intervalInput), interval > 0 {
            if interval != viewModel.settings.interval {
                viewModel.updateInterval(interval)
            }
        }
        
        viewModel.showingPreferences = false
    }
}

