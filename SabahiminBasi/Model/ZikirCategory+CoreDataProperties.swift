import Foundation
import CoreData

extension ZikirCategory {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ZikirCategory> {
        return NSFetchRequest<ZikirCategory>(entityName: "ZikirCategory")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var categoryDescription: String
    @NSManaged public var type: String // "morning", "evening", "daily", "special", "custom"
    @NSManaged public var icon: String
    @NSManaged public var createdAt: Date
    @NSManaged public var zikirs: NSSet?
    
    public var zikirArray: [Zikir] {
        let set = zikirs as? Set<Zikir> ?? []
        return set.sorted { $0.createdAt < $1.createdAt }
    }
}

extension ZikirCategory: Identifiable {} 