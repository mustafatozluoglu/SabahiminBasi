import Foundation
import Combine

public class ZikirDetailViewModel: ObservableObject {
    @Published public var zikir: Zikir
    @Published public var showCompletionAlert = false
    private let repository: ZikirRepository
    
    public init(zikir: Zikir, repository: ZikirRepository) {
        self.zikir = zikir
        self.repository = repository
    }
    
    public func incrementCount() {
        var newCount = zikir.count + 1
        var newCompletions = zikir.completions
        
        if newCount == zikir.targetCount {
            newCount = 0
            newCompletions += 1
            showCompletionAlert = true
        }
        
        zikir = Zikir(
            id: zikir.id,
            name: zikir.name,
            description: zikir.description,
            count: newCount,
            targetCount: zikir.targetCount,
            completions: newCompletions,
            createdAt: zikir.createdAt
        )
        repository.update(zikir)
    }
    
    public func resetCount() {
        zikir = Zikir(
            id: zikir.id,
            name: zikir.name,
            description: zikir.description,
            count: 0,
            targetCount: zikir.targetCount,
            completions: zikir.completions,
            createdAt: zikir.createdAt
        )
        repository.update(zikir)
    }
    
    public func updateTargetCount(_ newTarget: Int) {
        zikir = Zikir(
            id: zikir.id,
            name: zikir.name,
            description: zikir.description,
            count: zikir.count,
            targetCount: newTarget,
            completions: zikir.completions,
            createdAt: zikir.createdAt
        )
        repository.update(zikir)
    }
}
