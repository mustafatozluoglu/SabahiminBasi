import Foundation

public struct Zikir: Identifiable, Codable, Equatable {
    public var id: UUID
    public var name: String
    public var description: String
    public var count: Int
    public var targetCount: Int
    public var completions: Int
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String,
        count: Int = 0,
        targetCount: Int = 33,
        completions: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.count = count
        self.targetCount = targetCount
        self.completions = completions
        self.createdAt = createdAt
    }
}
