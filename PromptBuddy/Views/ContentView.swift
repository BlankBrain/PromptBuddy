import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var viewModel = PromptViewModel()
    @State private var showingNewPromptSheet = false
    @State private var selectedPromptID: UUID?
    @State private var showingAddCategoryAlert = false
    @State private var newCategoryName = ""
    @State private var selectedPrompt: Prompt? = nil
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        ZStack {
            // Modern blurred gradient background
            LinearGradient(gradient: Gradient(colors: [Color(.systemGray6), Color(.systemGray4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Favorites Section
                    GlassSection(title: "Favorites", systemImage: "star.fill") {
                        if viewModel.favoritePrompts.isEmpty {
                            Text("No favorites yet.")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 16)
                        } else {
                            ForEach(viewModel.favoritePrompts, id: \.id) { prompt in
                                GlassListItem {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                        Text(prompt.name)
                                            .fontWeight(.medium)
                                        Spacer()
                                    }
                                }
                                .onTapGesture {
                                    selectedPrompt = prompt
                                    selectedPromptID = prompt.id
                                    viewModel.incrementUsage(for: prompt)
                                }
                            }
                        }
                    }
                    // Most Used Section
                    GlassSection(
                        title: "Most Used",
                        systemImage: "flame.fill",
                        trailingHeader: {
                            Button(action: {
                                viewModel.resetAllUsage()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Reset Usage")
                                }
                                .font(.caption)
                            }
                            .buttonStyle(.bordered)
                        }
                    ) {
                        if viewModel.mostUsedPrompts.isEmpty {
                            Text("No prompts yet.")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 16)
                        } else {
                            ForEach(viewModel.mostUsedPrompts, id: \.id) { prompt in
                                GlassListItem {
                                    HStack {
                                        Text(prompt.name)
                                            .fontWeight(.medium)
                                        Spacer()
                                        if prompt.usageCount > 0 {
                                            Text("\(prompt.usageCount)")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .onTapGesture {
                                    selectedPrompt = prompt
                                    selectedPromptID = prompt.id
                                    viewModel.incrementUsage(for: prompt)
                                }
                            }
                        }
                    }
                    // Categories Section
                    GlassSection(
                        title: "Categories",
                        systemImage: "folder.fill",
                        trailingHeader: {
                            Button(action: {
                                showingAddCategoryAlert = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 36, height: 36)
                                        .shadow(radius: 4)
                                    Image(systemName: "plus")
                                        .font(.title3)
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .buttonStyle(.plain)
                            .alert("Add Category", isPresented: $showingAddCategoryAlert) {
                                TextField("Category name", text: $newCategoryName)
                                Button("Add", action: {
                                    viewModel.addCategory(newCategoryName)
                                    newCategoryName = ""
                                })
                                Button("Cancel", role: .cancel, action: {
                                    newCategoryName = ""
                                })
                            }
                        }
                    ) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            GlassListItem {
                                Text(category)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 32)
                .padding(.bottom, 16)
            }
            .safeAreaInset(edge: .bottom) {
                // Floating new prompt button with text
                HStack {
                    Spacer()
                    Button(action: {
                        showingNewPromptSheet = true
                    }) {
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 44, height: 44)
                                    .shadow(radius: 8)
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                            }
                            Text("Add Prompt")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.trailing, 8)
                        }
                        .padding(.horizontal, 4)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .shadow(radius: 8)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 24)
                    .padding(.bottom, 8)
                }
            }
        }
        .sheet(isPresented: $showingNewPromptSheet) {
            NewPromptView(viewModel: viewModel)
        }
        .sheet(item: $selectedPrompt) { prompt in
            PromptDetailView(promptID: prompt.id, viewModel: viewModel)
        }
    }
}

// Glass Section Container
struct GlassSection<Content: View, TrailingHeader: View>: View {
    let title: String
    let systemImage: String?
    let trailingHeader: (() -> TrailingHeader)?
    let content: () -> Content
    
    // With trailingHeader
    init(title: String, systemImage: String? = nil, @ViewBuilder trailingHeader: @escaping () -> TrailingHeader, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.trailingHeader = trailingHeader
        self.content = content
    }
    // Without trailingHeader (defaults to EmptyView)
    init(title: String, systemImage: String? = nil, @ViewBuilder content: @escaping () -> Content) where TrailingHeader == EmptyView {
        self.title = title
        self.systemImage = systemImage
        self.trailingHeader = nil
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .foregroundColor(.accentColor)
                        .font(.headline)
                }
                Text(title.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Spacer()
                if let trailingHeader = trailingHeader {
                    trailingHeader()
                }
            }
            .padding(.top, 8)
            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.07), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
    }
}

// Glass List Item
struct GlassListItem<Content: View>: View {
    let content: () -> Content
    var body: some View {
        HStack {
            content()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
        )
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 