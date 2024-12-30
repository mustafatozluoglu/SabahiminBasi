//
//  Persistence.swift
//  SabahiminBasi
//
//  Created by Mustafa Said Tozluoglu on 7.12.2024.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SabahiminBasi")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Core Data store failed to load: \(error.localizedDescription)")
            }
            
            description.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
            description.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
        }
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Preview Helper
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample data
        let sampleZikir = Zikir(context: viewContext)
        sampleZikir.id = UUID()
        sampleZikir.name = "Subhanallah"
        sampleZikir.zikirDescription = "Allah'ı tüm eksikliklerden tenzih ederim"
        sampleZikir.count = 0
        sampleZikir.targetCount = 33
        sampleZikir.completions = 0
        sampleZikir.createdAt = Date()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return result
    }()
}
