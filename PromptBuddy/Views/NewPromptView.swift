import SwiftUI

struct NewPromptView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var content = ""
    @State private var selectedCategory: String = ""
    private let viewModel: PromptViewModel
    
    init(viewModel: PromptViewModel) {
        self.viewModel = viewModel
        if let first = viewModel.categories.first {
            _selectedCategory = State(initialValue: first)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                } header: {
                    Text("Prompt Content")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Prompt")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let prompt = Prompt(
                            name: name,
                            content: content,
                            category: selectedCategory
                        )
                        viewModel.addPrompt(prompt)
                        dismiss()
                    }
                    .disabled(name.isEmpty || content.isEmpty || selectedCategory.isEmpty)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 500)
    }
}

#Preview {
    let vm = PromptViewModel()
    vm.addCategory("General")
    return NewPromptView(viewModel: vm)
} 