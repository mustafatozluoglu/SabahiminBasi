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
            SplashScreenView() // Show splash screen first
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        // Transition to the main content
                        let mainView = ZikirListView()
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                            .preferredColorScheme(darkModeEnabled ? .dark : .light)
                            .environmentObject(languageManager)
                        UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: mainView)
                    }
                }
        }
    }
}
