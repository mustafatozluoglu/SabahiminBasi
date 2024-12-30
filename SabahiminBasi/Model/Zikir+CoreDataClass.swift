import Foundation
import CoreData
import SwiftUI

@objc(Zikir)
public class Zikir: NSManagedObject {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
        setPrimitiveValue(Date(), forKey: "createdAt")
        setPrimitiveValue(0, forKey: "count")
        setPrimitiveValue(33, forKey: "targetCount")
        setPrimitiveValue(0, forKey: "completions")
    }
}
