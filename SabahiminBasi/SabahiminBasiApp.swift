import SwiftUI
import CoreData

@main
struct SabahiminBasiApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @StateObject private var languageManager = LanguageManager.shared
    
    init() {
        // Set initial language
        Bundle.setLanguage(LanguageManager.shared.currentLanguage)
    }
    
    var body: some Scene {
        WindowGroup {
            ZikirListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(darkModeEnabled ? .dark : .light)
                .environmentObject(languageManager)
        }
    }
}
