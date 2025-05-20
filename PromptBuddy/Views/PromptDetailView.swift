import SwiftUI

struct PromptDetailView: View {
    let promptID: UUID
    @ObservedObject var viewModel: PromptViewModel
    @State private var isEditing = false
    @State private var editedPrompt: Prompt?
    @State private var showDeleteAlert = false // For delete confirmation
    @Environment(\.dismiss) private var dismiss // For closing the sheet
    
    private var prompt: Prompt? {
        viewModel.prompts.first(where: { $0.id == promptID })
    }
    
    var body: some View {
        ZStack {
            // App background gradient (matches homepage/category sheet)
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.listBackground.blend(with: AppColors.primary, fraction: 0.25),
                    AppColors.secondary.blend(with: AppColors.primary, fraction: 0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ZStack(alignment: .topTrailing) {
                // Glassmorphic card background
                #if os(macOS)
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColors.listBackground.opacity(0.98))
                    .shadow(color: .black.opacity(0.10), radius: 24, x: 0, y: 12)
                #else
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(AppColors.listBackground.opacity(0.95))
                    .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
                #endif
                
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            // Title
                            Text("Prompt Details")
                                #if os(macOS)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                #else
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                #endif
                                .foregroundColor(AppColors.primary)
                            // Category badge
                            if let prompt = prompt {
                                HStack(spacing: 8) {
                                    Image(systemName: "tag.fill")
                                        .foregroundColor(AppColors.secondary)
                                    Text(prompt.category)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(AppColors.secondary.opacity(0.18))
                                        .clipShape(Capsule())
                                        .foregroundColor(AppColors.primary)
                                }
                            }
                        }
                        Spacer()
                        // Delete button
                        if let prompt = prompt {
                            HStack(spacing: 16) {
                                Button {
                                    showDeleteAlert = true
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        #if os(macOS)
                                        .font(.system(size: 32))
                                        #else
                                        .font(.system(size: 26))
                                        #endif
                                }
                                .buttonStyle(.plain)
                                // Favorite star
                                Button {
                                    viewModel.toggleFavorite(prompt)
                                } label: {
                                    Image(systemName: prompt.isFavorite ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
                                        #if os(macOS)
                                        .font(.system(size: 34))
                                        #else
                                        .font(.system(size: 28))
                                        #endif
                                        .shadow(radius: 2)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    Divider()
                    if let prompt = prompt {
                        if isEditing {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Name")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Name", text: Binding(
                                    get: { editedPrompt?.name ?? prompt.name },
                                    set: { editedPrompt?.name = $0 }
                                ))
                                .textFieldStyle(.roundedBorder)
                                #if os(macOS)
                                .font(.system(size: 20, weight: .regular, design: .default))
                                #else
                                .font(AppFonts.label)
                                #endif
                                
                                Text("Prompt Content")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextEditor(text: Binding(
                                    get: { editedPrompt?.content ?? prompt.content },
                                    set: { editedPrompt?.content = $0 }
                                ))
                                .frame(minHeight: 120)
                                .padding(6)
                                .background(AppColors.listBackground.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Name")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(prompt.name)
                                    #if os(macOS)
                                    .font(.system(size: 20, weight: .regular, design: .default))
                                    #else
                                    .font(AppFonts.label)
                                    #endif
                                    .foregroundColor(AppColors.label)
                                
                                Text("Prompt Content")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(prompt.content)
                                    .font(.body)
                                    .foregroundColor(AppColors.label)
                                    .padding(8)
                                    .background(AppColors.secondary.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .textSelection(.enabled)
                            }
                        }
                        Divider()
                        HStack(spacing: 20) {
                            if isEditing {
                                Button("Save") {
                                    if var updated = editedPrompt {
                                        viewModel.updatePrompt(updated)
                                    }
                                    isEditing = false
                                    editedPrompt = nil
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(AppColors.button)
                                #if os(macOS)
                                .font(.system(size: 18, weight: .medium))
                                #endif
                                Button("Cancel") {
                                    isEditing = false
                                    editedPrompt = nil
                                }
                                .buttonStyle(.bordered)
                                #if os(macOS)
                                .font(.system(size: 18, weight: .medium))
                                #endif
                            } else {
                                Button("Edit") {
                                    editedPrompt = prompt
                                    isEditing = true
                                }
                                .buttonStyle(.bordered)
                                #if os(macOS)
                                .font(.system(size: 18, weight: .medium))
                                #endif
                                Button("Copy to Clipboard") {
                                    #if os(macOS)
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(prompt.content, forType: .string)
                                    #elseif os(iOS)
                                    UIPasteboard.general.string = prompt.content
                                    #endif
                                }
                                .buttonStyle(.bordered)
                                #if os(macOS)
                                .font(.system(size: 18, weight: .medium))
                                #endif
                            }
                        }
                    } else {
                        Text("Prompt not found.")
                            .foregroundStyle(.secondary)
                    }
                }
                #if os(macOS)
                .padding(36)
                #else
                .padding(28)
                #endif
            }
            #if os(macOS)
            .padding(.horizontal, 16)
            .padding(.vertical, 32)
            .frame(minWidth: 500, minHeight: 400)
            #else
            .padding(.horizontal, 8)
            .padding(.vertical, 24)
            #endif
            // Dynamic sheet sizing for iOS 16+
            .ifAvailableiOS16 { view in
                view.presentationDetents([.medium, .large])
            }
            // Delete confirmation alert
            .alert("Delete Prompt?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let prompt = prompt {
                        viewModel.deletePrompt(prompt)
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this prompt? This action cannot be undone.")
            }
        }
    }
}

// MARK: - View Modifier for iOS 16+ Sheet Detents
extension View {
    @ViewBuilder
    func ifAvailableiOS16<Content: View>(@ViewBuilder _ transform: (Self) -> Content) -> some View {
        if #available(iOS 16.0, *) {
            transform(self)
        } else {
            self
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