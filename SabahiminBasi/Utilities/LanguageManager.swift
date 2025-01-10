import Foundation
import SwiftUI

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    @AppStorage("selectedLanguage") var currentLanguage: String = "en"
    
    private init() {}
    
    func setLanguage(_ languageCode: String) {
        currentLanguage = languageCode
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Force update the bundle
        Bundle.setLanguage(languageCode)
        
        // Post notification for views to update
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
    }
}

// Extension to handle bundle switching
extension Bundle {
    private static var bundle: Bundle?
    
    static func setLanguage(_ language: String) {
        let bundlePath = Bundle.main.path(forResource: language, ofType: "lproj")
        bundle = bundlePath != nil ? Bundle(path: bundlePath!) : Bundle.main
    }
    
    static func localizedString(forKey key: String) -> String {
        return bundle?.localizedString(forKey: key, value: nil, table: nil) ??
            Bundle.main.localizedString(forKey: key, value: nil, table: nil)
    }
}
