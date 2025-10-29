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
    @FocusState private var focusedField: Field?
    
    enum Field {
        case host
        case interval
    }
    
    enum SettingsTab: String, CaseIterable {
        case general
        case about
        
        var localizedName: String {
            switch self {
            case .general: return "preferences.tab.general".localized()
            case .about: return "preferences.tab.about".localized()
            }
        }
        
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
                            Text(tab.localizedName)
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
        .frame(width: 700)
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
            if !isInitialized {
                hostInput = viewModel.settings.host
                intervalInput = String(format: "%.0f", viewModel.settings.interval)
                isInitialized = true
            }
            // Empêcher le focus automatique sur les TextFields
            focusedField = nil
        }
        .onAppear {
            updateWindowTitle()
            resizeWindowToFitContent()
            // Empêcher le focus automatique au niveau de la fenêtre
            preventAutoFocus()
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
                    Text("preferences.general.target_host".localized())
                        .fontWeight(.bold)
                        .frame(width: 300, alignment: .trailing)
                    
                    // Column 2: Input
                    TextField("preferences.general.target_host.placeholder".localized(), text: $hostInput)
                        .textFieldStyle(.plain)
                        .focused($focusedField, equals: .host)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color(nsColor: .quaternaryLabelColor).opacity(0.75))
                        .cornerRadius(6)
                        .frame(width: 150, height: 24)
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
                    Text("preferences.general.update_interval".localized())
                        .fontWeight(.bold)
                        .frame(width: 300, alignment: .trailing)
                    
                    // Column 2: Input (petit pour 2 caractères max)
                    TextField("1", text: $intervalInput)
                        .textFieldStyle(.plain)
                        .focused($focusedField, equals: .interval)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
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
                    Text("preferences.general.update_interval.unit".localized())
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                // Display Mode row
                HStack(alignment: .center, spacing: 12) {
                    // Column 1: Label
                    Text("preferences.general.display_mode.show_icon".localized())
                        .fontWeight(.bold)
                        .frame(width: 300, alignment: .trailing)
                    
                    // Column 2: Checkbox
                    Toggle(isOn: Binding(
                        get: { viewModel.settings.showIconInMenuBar },
                        set: { viewModel.settings.showIconInMenuBar = $0 }
                    )) {
                        EmptyView()
                    }
                    .toggleStyle(.checkbox)
                    .help("preferences.general.display_mode.tooltip".localized())
                    
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
            HStack(alignment: .center, spacing: 20) {
                // Colonne gauche : Icône (centrée)
                VStack {
                    if let appIcon = loadAppIcon() {
                        Image(nsImage: appIcon)
                            .resizable()
                            .interpolation(.high)
                            .antialiased(true)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 64, height: 64)
                    } else {
                        Image(systemName: "network")
                            .font(.system(size: 48))
                            .foregroundColor(.accentColor)
                            .frame(width: 64, height: 64)
                    }
                }
                .frame(width: 160, alignment: .center)
                
                // Colonne droite : Texte
                VStack(alignment: .leading, spacing: 8) {
                    Text("preferences.about.app_name".localized())
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("preferences.about.version".localized())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("preferences.about.description".localized())
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("preferences.about.license".localized())
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    
                    Text("preferences.about.copyright".localized())
                        .font(.caption)
                        .foregroundColor(.secondary)
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
                    Text("preferences.about.acknowledgements".localized())
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
                    Text("preferences.about.visit_website".localized())
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
                    Text("preferences.about.send_feedback".localized())
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
    
    /// Charge l'icône de l'application en haute résolution
    private func loadAppIcon() -> NSImage? {
        // Essayer de charger le fichier .icns
        if let iconURL = Bundle.module.url(forResource: "icon", withExtension: "icns"),
           let imageData = try? Data(contentsOf: iconURL),
           let appIcon = NSImage(data: imageData) {
            // Forcer NSImage à utiliser la plus haute résolution disponible dans le .icns
            appIcon.size = NSSize(width: 512, height: 512)
            return appIcon
        }
        
        // Fallback : essayer le PNG
        if let iconURL = Bundle.module.url(forResource: "menubar-icon", withExtension: "png"),
           let imageData = try? Data(contentsOf: iconURL),
           let appIcon = NSImage(data: imageData) {
            return appIcon
        }
        
        return nil
    }
    
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

                let titleField = NSTextField(labelWithString: selectedTab.localizedName)
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
    
    /// Empêche le focus automatique sur les TextFields lors de l'ouverture de la fenêtre
    private func preventAutoFocus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let window = NSApplication.shared.windows.first(where: { 
                $0.identifier?.rawValue == "settings" 
            }) {
                // Retirer le premier responder pour empêcher le focus automatique
                window.makeFirstResponder(nil)
            }
        }
    }
}

