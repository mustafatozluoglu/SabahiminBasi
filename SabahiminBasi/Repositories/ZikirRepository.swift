import Foundation
import Combine

public protocol ZikirRepository {
    var zikirs: CurrentValueSubject<[Zikir], Never> { get }
    func add(_ zikir: Zikir)
    func update(_ zikir: Zikir)
    func delete(_ zikir: Zikir)
    func load()
}

public class DefaultZikirRepository: ZikirRepository {
    private let storageService: StorageService
    private let storageKey = "zikirs"
    public let zikirs = CurrentValueSubject<[Zikir], Never>([])
    
    public init(storageService: StorageService) {
        self.storageService = storageService
    }
    
    public func add(_ zikir: Zikir) {
        var current = zikirs.value
        current.append(zikir)
        zikirs.send(current)
        save()
    }
    
    public func update(_ zikir: Zikir) {
        var current = zikirs.value
        if let index = current.firstIndex(where: { $0.id == zikir.id }) {
            current[index] = zikir
            zikirs.send(current)
            save()
        }
    }
    
    public func delete(_ zikir: Zikir) {
        var current = zikirs.value
        current.removeAll(where: { $0.id == zikir.id })
        zikirs.send(current)
        save()
    }
    
    public func load() {
        do {
            if let stored: [Zikir] = try storageService.load(forKey: storageKey) {
                zikirs.send(stored)
            }
        } catch {
            print("Error loading zikirs: \(error)")
        }
    }
    
    private func save() {
        do {
            try storageService.save(zikirs.value, forKey: storageKey)
        } catch {
            print("Error saving zikirs: \(error)")
        }
    }
}
