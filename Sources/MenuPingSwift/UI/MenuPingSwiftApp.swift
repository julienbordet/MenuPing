//
// MenuPingSwiftApp.swift
// MenuPingSwift
//
// Point d'entrée principal de l'application.
// Configure la barre de menus avec MenuBarExtra et la fenêtre de préférences.
// Utilise @Observable moderne (macOS 15+)
//

import SwiftUI
import AppKit

@main
struct MenuPingSwiftApp: App {
    @State private var viewModel = AppViewModel()
    @Environment(\.openURL) private var openURL
    @Environment(\.openWindow) private var openWindow
    
    init() {
        // Observer pour détecter quand la fenêtre de settings se ferme
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: nil,
            queue: .main
        ) { notification in
            // Extraire l'objet notification avant d'entrer dans MainActor.assumeIsolated
            guard let window = notification.object as? NSWindow else { return }
            
            // Le closure s'exécute déjà sur la main queue
            MainActor.assumeIsolated {
                guard window.identifier?.rawValue == "settings" else { return }
                
                // Retourner à l'état "accessory" (menu bar uniquement)
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }
    
    var body: some Scene {
        // Menu bar item
        MenuBarExtra {
            MenuView(viewModel: viewModel)
        } label: {
            HStack(spacing: 4) {
                // Custom icon from resources
                if let iconURL = Bundle.module.url(forResource: "menubar-icon", withExtension: "png"),
                   let iconImage = NSImage(contentsOf: iconURL) {
                    Image(nsImage: iconImage)
                        .renderingMode(.template)
                        .opacity(viewModel.isError ? 0.5 : 1.0)
                } else {
                    // Fallback to SF Symbol if custom icon fails to load
                    Image(systemName: viewModel.isError ? "wifi.exclamationmark" : "wifi")
                }
                
                if let latency = viewModel.latency {
                    Text(String(format: "%.0f", latency))
                } else {
                    Text("—")
                }
            }
        }
        
        // Settings window - macOS 15+ moderne
        Window("", id: "settings") {
            PreferencesView(viewModel: viewModel)
                .onAppear {
                    // Centrer la fenêtre programmatiquement pour plus de fiabilité
                    centerSettingsWindow()
                }
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .defaultSize(width: 500, height: 180)
    }
    
    /// Centre la fenêtre de settings sur l'écran principal et configure son comportement
    private func centerSettingsWindow() {
        // Attendre que la fenêtre soit créée
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if let window = NSApplication.shared.windows.first(where: { 
                $0.identifier?.rawValue == "settings" 
            }) {
                window.center()
                
                // Masquer le titre dans la barre de titre et rendre la barre transparente
                window.titleVisibility = .hidden
                window.titlebarAppearsTransparent = true
                window.styleMask.insert(.fullSizeContentView)
                
                // Supprimer la ligne horizontale sous la barre de titre
                // (un _NSLayerBasedFillColorView de 1px de hauteur)
                @MainActor func hideHorizontalSeparators(_ view: NSView) {
                    let frame = view.frame
                    // Masquer les vues qui ressemblent à des séparateurs horizontaux
                    if view.className.contains("NSTitlebarSeparator") ||
                       view.className.contains("Separator") ||
                       view.className.contains("Divider") ||
                       (frame.height < 2 && frame.width > 100) {
                        view.isHidden = true
                    }
                    
                    for subview in view.subviews {
                        hideHorizontalSeparators(subview)
                    }
                }
                
                // Masquer immédiatement
                if let frameView = window.contentView?.superview {
                    hideHorizontalSeparators(frameView)
                }
                
                // Masquer à nouveau après un délai (la ligne peut apparaître plus tard)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let frameView = window.contentView?.superview {
                        hideHorizontalSeparators(frameView)
                    }
                }
                
                // Et encore une fois pour être sûr
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if let frameView = window.contentView?.superview {
                        hideHorizontalSeparators(frameView)
                    }
                }
                
                // Configure la fenêtre pour qu'elle reste accessible via Cmd+Tab
                // et ne se ferme pas automatiquement en perdant le focus
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                window.level = .normal
                window.isReleasedWhenClosed = false
                
                // S'assurer que l'app apparaît dans le Dock et le App Switcher quand la fenêtre est ouverte
                NSApp.setActivationPolicy(.regular)
            }
        }
    }
}

