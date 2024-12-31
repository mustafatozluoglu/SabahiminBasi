import Foundation
import CoreData

class ZikirDetailViewModel: ObservableObject {
    @Published var zikir: Zikir
    private var viewContext: NSManagedObjectContext
    
    init(zikir: Zikir, viewContext: NSManagedObjectContext) {
        self.zikir = zikir
        self.viewContext = viewContext
    }
    
    var selectedCategory: ZikirCategory? {
        get { zikir.category }
        set {
            viewContext.perform {
                self.zikir.category = newValue
                self.saveContext()
            }
        }
    }
    
    func incrementCount() {
        viewContext.perform {
            self.zikir.count += 1
            if self.zikir.count >= self.zikir.targetCount {
                self.zikir.completions += 1
                self.zikir.count = 0
                self.zikir.lastCompletedDate = Date()
            }
            self.saveContext()
        }
    }
    
    func resetCount() {
        viewContext.perform {
            self.zikir.count = 0
            self.saveContext()
        }
    }
    
    func updateTargetCount(_ newTarget: Int32) {
        viewContext.perform {
            self.zikir.targetCount = newTarget
            self.saveContext()
        }
    }
    
    func updateZikir(name: String, description: String, targetCount: Int32) {
        viewContext.perform {
            self.zikir.name = name
            self.zikir.zikirDescription = description
            self.zikir.targetCount = targetCount
            self.saveContext()
        }
    }
    
    func toggleFavorite() {
        viewContext.perform {
            self.zikir.favorite.toggle()
            self.saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
