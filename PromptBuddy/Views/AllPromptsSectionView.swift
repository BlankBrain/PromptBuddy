import SwiftUI

struct AllPromptsSectionView: View {
    @ObservedObject var viewModel: PromptViewModel
    var onPromptTap: (Prompt) -> Void
    @State private var searchText: String = ""
    var filteredPrompts: [Prompt] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return viewModel.prompts
        } else {
            let lower = searchText.lowercased()
            return viewModel.prompts.filter {
                $0.name.lowercased().contains(lower) || $0.content.lowercased().contains(lower)
            }
        }
    }
    var body: some View {
        GlassSection(title: "All Prompts", systemImage: "tray.full.fill") {
            // Modern search bar below header
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(8)
                    .background(AppColors.listBackground.opacity(0.7))
                    .cornerRadius(10)
            }
            .padding(.bottom, 8)
            // Prompt list fills available space
            if filteredPrompts.isEmpty {
                Text("No prompts found.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(filteredPrompts, id: \.id) { prompt in
                            AllPromptsRowView(prompt: prompt, onTap: { onPromptTap(prompt) })
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
    }
} 