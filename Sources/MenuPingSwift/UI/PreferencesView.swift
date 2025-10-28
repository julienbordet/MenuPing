//
// PreferencesView.swift
// MenuPingSwift
//
// Vue de configuration permettant de modifier l'hôte cible
// et l'intervalle de ping.
// Utilise @Observable et @Bindable moderne (macOS 15+)
//

import SwiftUI
import AppKit

/// Settings window view
struct PreferencesView: View {
    @Bindable var viewModel: AppViewModel
    @State private var hostInput: String = ""
    @State private var intervalInput: String = ""
    @State private var isInitialized = false
    @State private var selectedTab: SettingsTab = .general
    
    enum SettingsTab: String, CaseIterable {
        case general = "General"
        case about = "About"
        
        var icon: String {
            switch self {
            case .general: return "gearshape"
            case .about: return "info.circle"
            }
        }
    }
    
    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tabs - toujours visibles (style macOS System Settings)
            HStack(spacing: 4) {
                Spacer()
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        VStack(spacing: 2) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 16))
                                .imageScale(.large)
                            Text(tab.rawValue)
                                .font(.system(size: 11))
                        }
                        .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
                        .frame(width: 70, height: 60)
                        .background(
                            selectedTab == tab 
                                ? Color(nsColor: .controlBackgroundColor)
                                : Color.clear
                        )
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            Divider()
            
            // Content based on selected tab
            if selectedTab == .general {
                generalView
            } else {
                aboutView
            }
        }
        .frame(width: 500)
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
            if !isInitialized {
                hostInput = viewModel.settings.host
                intervalInput = String(format: "%.0f", viewModel.settings.interval)
                isInitialized = true
            }
        }
        .onAppear {
            updateWindowTitle()
            resizeWindowToFitContent()
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            // Mettre à jour le titre de la fenêtre quand on change de tab
            updateWindowTitle()
            resizeWindowToFitContent()
        }
    }
    
    // MARK: - General Tab
    
    var generalView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 16) {
                // Target Host row
                HStack(alignment: .center, spacing: 12) {
                    Text("Target Host:")
                        .fontWeight(.bold)
                        .frame(width: 120, alignment: .trailing)
                    
                    // Column 2: Input
                    TextField("e.g., www.google.com", text: $hostInput)
                        .textFieldStyle(.plain)
                        .padding(6)
                        .background(Color(nsColor: .quaternaryLabelColor).opacity(0.75))
                        .cornerRadius(6)
                        .frame(width: 220)
                        .onChange(of: hostInput) { oldValue, newValue in
                            let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty && trimmed != viewModel.settings.host {
                                viewModel.updateHost(trimmed)
                            }
                        }
                    
                    // Column 3: Description (empty for this field)
                    Spacer()
                }
                
                // Update Interval row
                HStack(alignment: .center, spacing: 12) {
                    // Column 1: Label
                    Text("Update Interval:")
                        .fontWeight(.bold)
                        .frame(width: 120, alignment: .trailing)
                    
                    // Column 2: Input (petit pour 2 caractères max)
                    TextField("1", text: $intervalInput)
                        .textFieldStyle(.plain)
                        .padding(6)
                        .background(Color(nsColor: .quaternaryLabelColor).opacity(0.75))
                        .cornerRadius(6)
                        .frame(width: 40)
                        .multilineTextAlignment(.center)
                        .onChange(of: intervalInput) { oldValue, newValue in
                            if let interval = Double(newValue), interval >= 0.1 {
                                if interval != viewModel.settings.interval {
                                    viewModel.updateInterval(interval)
                                }
                            }
                        }
                    
                    // Column 3: Unit
                    Text("second(s)")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    // MARK: - About Tab
    
    var aboutView: some View {
        VStack(spacing: 0) {
            // Content principal - Layout en deux colonnes
            HStack(alignment: .top, spacing: 20) {
                // Colonne gauche : Icône
                Group {
                    if let iconURL = Bundle.main.url(forResource: "icon", withExtension: "icns"),
                       let appIcon = NSImage(contentsOf: iconURL) {
                        Image(nsImage: appIcon)
                            .resizable()
                            .frame(width: 64, height: 64)
                    } else if let iconURL = Bundle.module.url(forResource: "menubar-icon", withExtension: "png"),
                              let appIcon = NSImage(contentsOf: iconURL) {
                        Image(nsImage: appIcon)
                            .resizable()
                            .frame(width: 64, height: 64)
                    } else {
                        Image(systemName: "network")
                            .font(.system(size: 48))
                            .foregroundColor(.accentColor)
                            .frame(width: 64, height: 64)
                    }
                }
                
                // Colonne droite : Texte
                VStack(alignment: .leading, spacing: 8) {
                    Text("MenuPing")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Monitor your internet connection latency")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("© 2025 Julien Bordet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 40)
            .padding(.top, 24)
            .padding(.bottom, 12)
            
            Spacer()
            
            // Footer avec boutons (comme Raycast)
            Divider()
            
            HStack(spacing: 6) {
                // Bouton Acknowledgements (gauche)
                Button(action: {
                    if let url = URL(string: "https://github.com/julienbordet/MenuPing#acknowledgements") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Text("Acknowledgements")
                        .font(.system(size: 11))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(Color(nsColor: .quaternaryLabelColor).opacity(0.75))
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                
                // Bouton Visit Website (centre)
                Button(action: {
                    if let url = URL(string: "https://github.com/julienbordet/MenuPing") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Text("Visit Website")
                        .font(.system(size: 11))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 4)
                        .background(Color(nsColor: .quaternaryLabelColor).opacity(0.75))
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                
                // Bouton Send Feedback (droite)
                Button(action: {
                    if let url = URL(string: "https://github.com/julienbordet/MenuPing/issues/new") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Text("Send Feedback")
                        .font(.system(size: 11))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 4)
                        .background(Color(nsColor: .quaternaryLabelColor).opacity(0.75))
                        .padding(.vertical, 10)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Helper Functions
    
    /// Met à jour le titre de la fenêtre pour refléter le tab sélectionné
    private func updateWindowTitle() {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first(where: { 
                $0.identifier?.rawValue == "settings" 
            }) {
                // Récupère la "titlebarView" (le conteneur des boutons)
                guard let titlebarView = window.standardWindowButton(.closeButton)?.superview else { return }

                // Supprime les anciens labels éventuels
                titlebarView.subviews
                    .filter { $0.tag == 5555 }
                    .forEach { $0.removeFromSuperview() }

                let titleField = NSTextField(labelWithString: selectedTab.rawValue)
                titleField.font = .systemFont(ofSize: 13, weight: .bold)
                titleField.textColor = .labelColor
                titleField.backgroundColor = .clear
                titleField.alignment = .center
                titleField.isBordered = false
                titleField.isBezeled = false
                titleField.isEditable = false
                titleField.isSelectable = false
                titleField.usesSingleLineMode = true
                titleField.translatesAutoresizingMaskIntoConstraints = false
                titleField.tag = 5555
                
                titlebarView.addSubview(titleField)
                
                // Contraintes pour occuper tout l'espace et centrer verticalement
                NSLayoutConstraint.activate([
                    titleField.leadingAnchor.constraint(equalTo: titlebarView.leadingAnchor),
                    titleField.trailingAnchor.constraint(equalTo: titlebarView.trailingAnchor),
                    titleField.centerYAnchor.constraint(equalTo: titlebarView.centerYAnchor),
                    titleField.heightAnchor.constraint(equalToConstant: 20)
                ])
            }
        }
    }

    private func resizeWindowToFitContent() {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first(where: { 
                $0.identifier?.rawValue == "settings" 
            }) {
                if let contentView = window.contentView {
                   let fittingSize = contentView.fittingSize
                   window.setContentSize(fittingSize)
                }
            }
        }
    }
}

