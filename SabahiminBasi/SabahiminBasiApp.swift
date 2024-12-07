//
//  SabahiminBasiApp.swift
//  SabahiminBasi
//
//  Created by Mustafa Said Tozluoglu on 7.12.2024.
//

import SwiftUI

@main
struct SabahiminBasiApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
