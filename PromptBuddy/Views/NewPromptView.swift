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
        ZStack {
            // App gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.listBackground.blend(with: AppColors.primary, fraction: 0.25),
                    AppColors.secondary.blend(with: AppColors.primary, fraction: 0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Glass card with PromptDetailView-style sizing
            ZStack {
                // Glassmorphic card background
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.10),
                                Color.white.opacity(0.04)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white.opacity(0.22), lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.18), radius: 32, x: 0, y: 16)
                    .blur(radius: 0.1)
                VStack(alignment: .leading, spacing: 0) {
                    // Title & Subtitle
                    VStack(alignment: .leading, spacing: 4) {
                        Text("New Prompt")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.primary)
                        Text("Create a new prompt to use in your workflow.")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 18)
                    // Form fields
                    VStack(alignment: .leading, spacing: 16) {
                        // Name
                        TextField("Name", text: $name)
                            .padding(12)
                            .background(Color.white.opacity(0.18))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
                            )
                            .cornerRadius(12)
                            .font(AppFonts.label)
                        // Category
                        HStack {
                            Text("Category")
                                .font(.body)
                                .foregroundColor(.secondary)
                            Spacer()
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(viewModel.categories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.18))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
                            )
                            .cornerRadius(10)
                        }
                        // Content
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Prompt Content")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextEditor(text: $content)
                                .frame(minHeight: 100, maxHeight: 150)
                                .padding(10)
                                .background(Color.white.opacity(0.18))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                                )
                                .cornerRadius(12)
                                .font(AppFonts.label)
                        }
                    }
                    .padding(.bottom, 8)
                    // Buttons at the bottom
                    HStack {
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .font(.system(size: 17, weight: .regular, design: .rounded))
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                        }
                        Button(action: {
                            let prompt = Prompt(
                                name: name,
                                content: content,
                                category: selectedCategory
                            )
                            viewModel.addPrompt(prompt)
                            dismiss()
                        }) {
                            Text("Save")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background((name.isEmpty || content.isEmpty || selectedCategory.isEmpty) ? Color.gray.opacity(0.18) : AppColors.primary)
                                .foregroundColor((name.isEmpty || content.isEmpty || selectedCategory.isEmpty) ? .gray : .white)
                                .clipShape(Capsule())
                                .shadow(color: (name.isEmpty || content.isEmpty || selectedCategory.isEmpty) ? .clear : AppColors.primary.opacity(0.18), radius: 8, x: 0, y: 4)
                        }
                        .disabled(name.isEmpty || content.isEmpty || selectedCategory.isEmpty)
                    }
                    .padding(.top, 16)
                }
                .padding(28)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 24)
            // Dynamic sheet sizing for iOS 16+
            .ifAvailableiOS16 { view in
                view.presentationDetents([.medium, .large])
            }
        }
    }
}


#Preview {
    let vm = PromptViewModel()
    vm.addCategory("General")
    return NewPromptView(viewModel: vm)
} 
