import SwiftUI

struct PromptDetailView: View {
    let promptID: UUID
    @ObservedObject var viewModel: PromptViewModel
    @State private var isEditing = false
    @State private var editedPrompt: Prompt?
    
    private var prompt: Prompt? {
        viewModel.prompts.first(where: { $0.id == promptID })
    }
    
    var body: some View {
        ScrollView {
            if let prompt = prompt {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Prompt Details")
                            .font(.title)
                            .bold()
                        Spacer()
                        Button {
                            viewModel.toggleFavorite(prompt)
                        } label: {
                            Image(systemName: prompt.isFavorite ? "star.fill" : "star")
                                .foregroundColor(prompt.isFavorite ? .yellow : .gray)
                                .imageScale(.large)
                        }
                        .buttonStyle(.plain)
                    }
                    if isEditing {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("Name", text: Binding(
                                get: { editedPrompt?.name ?? prompt.name },
                                set: { editedPrompt?.name = $0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                            .font(.title2)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Picker("Category", selection: Binding(
                                get: { editedPrompt?.category ?? prompt.category },
                                set: { editedPrompt?.category = $0 }
                            )) {
                                ForEach(viewModel.categories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Prompt Content")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextEditor(text: Binding(
                                get: { editedPrompt?.content ?? prompt.content },
                                set: { editedPrompt?.content = $0 }
                            ))
                            .frame(minHeight: 200)
                            .padding(4)
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(prompt.name)
                                .font(.title2)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(prompt.category)
                                .foregroundStyle(.primary)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Prompt Content")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(prompt.content)
                                .textSelection(.enabled)
                        }
                    }
                    
                    HStack {
                        if isEditing {
                            Button("Save") {
                                if var updated = editedPrompt {
                                    viewModel.updatePrompt(updated)
                                }
                                isEditing = false
                                editedPrompt = nil
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Cancel") {
                                isEditing = false
                                editedPrompt = nil
                            }
                            .buttonStyle(.bordered)
                        } else {
                            Button("Edit") {
                                editedPrompt = prompt
                                isEditing = true
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Copy to Clipboard") {
                                #if os(macOS)
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(prompt.content, forType: .string)
                                #elseif os(iOS)
                                UIPasteboard.general.string = prompt.content
                                #endif
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                .padding()
            } else {
                Text("Prompt not found.")
                    .foregroundStyle(.secondary)
            }
        }
        .background {
            Color.clear
                .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    let vm = PromptViewModel()
    vm.addCategory("General")
    let prompt = Prompt(name: "Example Prompt", content: "This is an example prompt content.", category: "General")
    vm.addPrompt(prompt)
    return PromptDetailView(promptID: prompt.id, viewModel: vm)
} 