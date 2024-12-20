import Foundation
import Combine

public class ZikirListViewModel: ObservableObject {
    @Published public var zikirs: [Zikir] = []
    public let repository: ZikirRepository
    private var cancellables = Set<AnyCancellable>()
    
    public init(repository: ZikirRepository) {
        self.repository = repository
        setupBindings()
    }
    
    private func setupBindings() {
        repository.zikirs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] zikirs in
                self?.zikirs = zikirs
            }
            .store(in: &cancellables)
    }
    
    public func add(name: String, description: String, targetCount: Int) {
        let zikir = Zikir(
            name: name,
            description: description,
            targetCount: targetCount
        )
        repository.add(zikir)
    }
    
    public func delete(_ zikir: Zikir) {
        repository.delete(zikir)
    }
    
    public func load() {
        repository.load()
    }
}
