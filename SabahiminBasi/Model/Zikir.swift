//
//  ZikirModel.swift
//  SabahiminBasi
//
//  Created by Mustafa Said Tozluoglu on 19.12.2024.
//

import Foundation

struct Zikir: Identifiable, Codable {
    var id = UUID()
    var name: String
    var description: String
    var count: Int
}

class ZikirStore: ObservableObject {
    @Published var zikirs: [Zikir] = [] {
        didSet {
            save()
        }
    }
    
    init() {
        load()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(zikirs) {
            UserDefaults.standard.set(encoded, forKey: "zikirs")
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: "zikirs"),
           let decoded = try? JSONDecoder().decode([Zikir].self, from: data) {
            zikirs = decoded
        }
    }
}
