import Foundation
import CoreData

extension Zikir {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Zikir> {
        return NSFetchRequest<Zikir>(entityName: "Zikir")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var zikirDescription: String
    @NSManaged public var count: Int32
    @NSManaged public var targetCount: Int32
    @NSManaged public var completions: Int32
    @NSManaged public var createdAt: Date
    @NSManaged public var lastCompletedDate: Date?
    @NSManaged public var favorite: Bool
    
    public var wrappedName: String {
        name
    }
}

extension Zikir: Identifiable {}
