import Foundation
import CoreData
import SwiftUI
import Combine

class ZikirDetailViewModel: ObservableObject {
    @Published var zikir: Zikir
    private var viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    init(zikir: Zikir, viewContext: NSManagedObjectContext) {
        self.zikir = zikir
        self.viewContext = viewContext
        
        // Set up notification observer for context changes
        NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave, object: viewContext)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.objectWillChange.send()
                if let zikir = self.zikir as NSManagedObject? {
                    self.viewContext.refresh(zikir, mergeChanges: true)
                }
            }
            .store(in: &cancellables)
    }
    
    var selectedCategory: ZikirCategory? {
        get { zikir.category }
        set {
            self.viewContext.perform { [weak self] in
                guard let self = self else { return }
                self.zikir.category = newValue
                self.saveContext()
            }
        }
    }
    
    func incrementCount() {
        self.viewContext.perform { [weak self] in
            guard let self = self else { return }
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
        self.viewContext.perform { [weak self] in
            guard let self = self else { return }
            self.zikir.count = 0
            self.saveContext()
        }
    }
    
    func updateTargetCount(_ newTarget: Int32) {
        self.viewContext.perform { [weak self] in
            guard let self = self else { return }
            self.zikir.targetCount = newTarget
            self.saveContext()
        }
    }
    
    func updateZikir(name: String, description: String, targetCount: Int32) {
        self.viewContext.perform { [weak self] in
            guard let self = self else { return }
            self.zikir.name = name
            self.zikir.zikirDescription = description
            self.zikir.targetCount = targetCount
            
            // Save and refresh immediately
            do {
                try self.viewContext.save()
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                    self.viewContext.refresh(self.zikir, mergeChanges: true)
                    NotificationCenter.default.post(
                        name: .NSManagedObjectContextDidSave,
                        object: self.viewContext,
                        userInfo: nil
                    )
                }
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    func toggleFavorite() {
        self.viewContext.perform { [weak self] in
            guard let self = self else { return }
            self.zikir.favorite.toggle()
            self.saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try self.viewContext.save()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.objectWillChange.send()
                self.viewContext.refresh(self.zikir, mergeChanges: true)
                NotificationCenter.default.post(
                    name: .NSManagedObjectContextDidSave,
                    object: self.viewContext,
                    userInfo: nil
                )
            }
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
