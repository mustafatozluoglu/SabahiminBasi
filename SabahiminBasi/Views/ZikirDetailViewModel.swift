import Foundation
import Combine
import CoreData

public class ZikirDetailViewModel: ObservableObject {
    @Published public var zikir: Zikir
    @Published public var isCompleted = false
    private let viewContext: NSManagedObjectContext
    
    public init(zikir: Zikir, viewContext: NSManagedObjectContext) {
        self.zikir = zikir
        self.viewContext = viewContext
    }
    
    public func incrementCount() {
        viewContext.perform {
            self.zikir.count += 1
            
            if self.zikir.count >= self.zikir.targetCount {
                self.zikir.completions += 1
                self.zikir.count = 0
                self.zikir.lastCompletedDate = Date()
                self.isCompleted = true
            }
            
            self.saveContext()
        }
    }
    
    public func resetCount() {
        viewContext.perform {
            self.zikir.count = 0
            self.saveContext()
        }
    }
    
    public func updateTargetCount(_ newTarget: Int32) {
        viewContext.perform {
            self.zikir.targetCount = newTarget
            self.saveContext()
        }
    }
    
    public func updateZikir(name: String, description: String, targetCount: Int32) {
        viewContext.perform {
            self.zikir.name = name
            self.zikir.zikirDescription = description
            self.zikir.targetCount = targetCount
            self.saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Error saving context: \(nsError), \(nsError.userInfo)")
        }
    }
}
