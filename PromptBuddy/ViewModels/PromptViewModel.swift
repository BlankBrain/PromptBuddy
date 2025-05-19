import Foundation
import SwiftUI
import Combine

@MainActor
class PromptViewModel: ObservableObject {
    @Published var prompts: [Prompt] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: String?
    @Published var sortOrder: SortOrder = .name
    @Published var categories: [String] = []
    
    private let saveKey = "savedPrompts"
    private let categoryKey = "savedCategories"
    
    enum SortOrder {
        case name
        case dateCreated
        case dateUpdated
    }
    
    init() {
        loadPrompts()
        loadCategories()
    }
    
    var filteredPrompts: [Prompt] {
        prompts
            .filter { prompt in
                let matchesSearch = searchText.isEmpty || 
                    prompt.name.localizedCaseInsensitiveContains(searchText)
                let matchesCategory = selectedCategory == nil || prompt.category == selectedCategory
                return matchesSearch && matchesCategory
            }
            .sorted { first, second in
                switch sortOrder {
                case .name:
                    return first.name < second.name
                case .dateCreated:
                    return first.createdAt > second.createdAt
                case .dateUpdated:
                    return first.updatedAt > second.updatedAt
                }
            }
    }
    
    func addCategory(_ category: String) {
        let trimmed = category.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !categories.contains(trimmed) else { return }
        categories.append(trimmed)
        categories.sort()
        saveCategories()
    }
    
    func addPrompt(_ prompt: Prompt) {
        prompts.append(prompt)
        savePrompts()
        if !categories.contains(prompt.category) {
            addCategory(prompt.category)
        }
    }
    
    func updatePrompt(_ prompt: Prompt) {
        if let index = prompts.firstIndex(where: { $0.id == prompt.id }) {
            prompts[index] = prompt
            savePrompts()
            if !categories.contains(prompt.category) {
                addCategory(prompt.category)
            }
        }
    }
    
    func deletePrompt(_ prompt: Prompt) {
        prompts.removeAll { $0.id == prompt.id }
        savePrompts()
    }
    
    func duplicatePrompt(_ prompt: Prompt) {
        var newPrompt = prompt
        newPrompt.id = UUID()
        newPrompt.name = "\(prompt.name) (Copy)"
        addPrompt(newPrompt)
    }
    
    private func savePrompts() {
        if let encoded = try? JSONEncoder().encode(prompts) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadPrompts() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Prompt].self, from: data) {
            prompts = decoded
        }
    }
    
    private func saveCategories() {
        UserDefaults.standard.set(categories, forKey: categoryKey)
    }
    
    private func loadCategories() {
        if let saved = UserDefaults.standard.stringArray(forKey: categoryKey) {
            categories = saved.sorted()
        } else {
            // If no saved categories, infer from prompts
            categories = Array(Set(prompts.map { $0.category })).sorted()
        }
    }
    
    var mostUsedPrompts: [Prompt] {
        if prompts.allSatisfy({ $0.usageCount == 0 }) {
            return prompts.sorted { $0.name < $1.name }.prefix(20).map { $0 }
        } else {
            return prompts.sorted { $0.usageCount > $1.usageCount }.prefix(20).map { $0 }
        }
    }

    func incrementUsage(for prompt: Prompt) {
        if let index = prompts.firstIndex(where: { $0.id == prompt.id }) {
            prompts[index].usageCount += 1
            savePrompts()
        }
    }

    func resetAllUsage() {
        for i in prompts.indices {
            prompts[i].usageCount = 0
        }
        savePrompts()
    }
} 