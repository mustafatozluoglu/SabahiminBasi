import Foundation
import Combine

public class ZikirDetailViewModel: ObservableObject {
    @Published public var zikir: Zikir
    private let repository: ZikirRepository
    
    public init(zikir: Zikir, repository: ZikirRepository) {
        self.zikir = zikir
        self.repository = repository
    }
    
    public func incrementCount() {
        zikir = Zikir(
            id: zikir.id,
            name: zikir.name,
            description: zikir.description,
            count: zikir.count + 1,
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
            createdAt: zikir.createdAt
        )
        repository.update(zikir)
    }
}
