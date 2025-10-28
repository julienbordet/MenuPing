//
// LocalizationHelper.swift
// MenuPingSwift
//
// Helper pour la localisation avec Bundle.module
//

import Foundation

extension String {
    /// Localise une chaîne depuis le Bundle.module avec détection explicite de la langue
    func localized() -> String {
        // Récupère la langue préférée
        let preferredLanguages = Locale.preferredLanguages
        let availableLocalizations = ["en", "fr"]
        
        // Trouve la meilleure correspondance
        var languageCode = "en"
        for preferredLanguage in preferredLanguages {
            let code = String(preferredLanguage.prefix(2))
            if availableLocalizations.contains(code) {
                languageCode = code
                break
            }
        }
        
        // Charge le bundle de localisation approprié
        if let bundlePath = Bundle.module.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: bundlePath) {
            return NSLocalizedString(self, bundle: bundle, comment: "")
        }
        
        // Fallback sur le bundle par défaut
        return NSLocalizedString(self, bundle: .module, comment: "")
    }
}

