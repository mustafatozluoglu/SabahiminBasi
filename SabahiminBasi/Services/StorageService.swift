import Foundation

public protocol StorageService {
    func save<T: Encodable>(_ item: T, forKey key: String) throws
    func load<T: Decodable>(forKey key: String) throws -> T?
}

public class UserDefaultsStorageService: StorageService {
    private let defaults: UserDefaults
    
    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    public func save<T: Encodable>(_ item: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(item)
        defaults.set(data, forKey: key)
    }
    
    public func load<T: Decodable>(forKey key: String) throws -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
