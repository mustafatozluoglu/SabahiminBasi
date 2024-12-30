import SwiftUI
import CoreData

@main
struct SabahiminBasiApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    
    var body: some Scene {
        WindowGroup {
            ZikirListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(darkModeEnabled ? .dark : .light)
                .onAppear {
                    // Set initial interface style
                    UIApplication.shared.windows.first?.overrideUserInterfaceStyle = darkModeEnabled ? .dark : .light
                }
        }
    }
}
