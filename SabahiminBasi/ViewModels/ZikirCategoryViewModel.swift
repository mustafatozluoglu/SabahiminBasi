import Foundation
import CoreData
import SwiftUI

class ZikirCategoryViewModel: ObservableObject {
    @Published var categories: [ZikirCategory] = []
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        createDefaultCategoriesIfNeeded()
        fetchCategories()
    }
    
    func fetchCategories() {
        let request = ZikirCategory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ZikirCategory.createdAt, ascending: true)]
        
        do {
            categories = try viewContext.fetch(request)
        } catch {
            print("Error fetching categories: \(error)")
        }
    }
    
    func createCategory(name: String, description: String, type: String, icon: String) {
        let category = ZikirCategory(context: viewContext)
        category.id = UUID()
        category.name = name
        category.categoryDescription = description
        category.type = type
        category.icon = icon
        category.createdAt = Date()
        
        saveContext()
    }
    
    func deleteCategory(_ category: ZikirCategory) {
        viewContext.delete(category)
        saveContext()
    }
    
    func addZikirToCategory(_ zikir: Zikir, category: ZikirCategory) {
        zikir.category = category
        saveContext()
    }
    
    func removeZikirFromCategory(_ zikir: Zikir) {
        zikir.category = nil
        saveContext()
    }
    
    private func createDefaultCategoriesIfNeeded() {
        let request = ZikirCategory.fetchRequest()
        
        do {
            let count = try viewContext.count(for: request)
            if count == 0 {
                // Create default categories
                let defaultCategories = [
                    (name: String(localized: "morning_dhikr"), description: String(localized: "morning_dhikr_description"), type: "morning", icon: "sunrise.fill"),
                    (name: String(localized: "evening_dhikr"), description: String(localized: "evening_dhikr_description"), type: "evening", icon: "sunset.fill"),
                    (name: String(localized: "daily_dhikr"), description: String(localized: "daily_dhikr_description"), type: "daily", icon: "clock.fill"),
                    (name: String(localized: "special_occasions"), description: String(localized: "special_occasions_description"), type: "special", icon: "star.fill")
                ]
                
                for category in defaultCategories {
                    createCategory(
                        name: category.name,
                        description: category.description,
                        type: category.type,
                        icon: category.icon
                    )
                }
            }
        } catch {
            print("Error checking for default categories: \(error)")
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
            fetchCategories()
        } catch {
            print("Error saving context: \(error)")
        }
    }
} 