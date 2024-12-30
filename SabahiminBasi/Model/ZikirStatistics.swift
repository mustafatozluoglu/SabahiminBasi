import Foundation

struct ZikirStatistics: Codable, Identifiable {
    let id: UUID
    let zikirId: UUID
    let date: Date
    let completedCount: Int
    let targetCount: Int
    
    var completionPercentage: Double {
        guard targetCount > 0 else { return 0 }
        return Double(completedCount) / Double(targetCount) * 100
    }
}

struct DailyStats: Identifiable {
    let id = UUID()
    let date: Date
    let totalCompletions: Int
    let totalZikirs: Int
    let completedZikirs: Int
    
    var completionRate: Double {
        guard totalZikirs > 0 else { return 0 }
        return Double(completedZikirs) / Double(totalZikirs) * 100
    }
}

struct WeeklyStats: Identifiable {
    let id = UUID()
    let weekStart: Date
    let weekEnd: Date
    let dailyStats: [DailyStats]
    
    var totalCompletions: Int {
        dailyStats.reduce(0) { $0 + $1.totalCompletions }
    }
    
    var averageCompletionRate: Double {
        let total = dailyStats.reduce(0.0) { $0 + $1.completionRate }
        return total / Double(dailyStats.count)
    }
}
