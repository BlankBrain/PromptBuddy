import Foundation

struct Prompt: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var content: String
    var category: String
    var createdAt: Date
    var updatedAt: Date
    var usageCount: Int
    var isFavorite: Bool
    
    init(id: UUID = UUID(), name: String, content: String, category: String, usageCount: Int = 0, isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.content = content
        self.category = category
        self.createdAt = Date()
        self.updatedAt = Date()
        self.usageCount = usageCount
        self.isFavorite = isFavorite
    }
    
    mutating func update(name: String? = nil, content: String? = nil, category: String? = nil, isFavorite: Bool? = nil) {
        if let name = name { self.name = name }
        if let content = content { self.content = content }
        if let category = category { self.category = category }
        if let isFavorite = isFavorite { self.isFavorite = isFavorite }
        self.updatedAt = Date()
    }
} 