import SwiftUI
import CoreData

// Helper struct to wrap category for sheet presentation
struct CategorySheetItem: Identifiable, Equatable {
    let id = UUID()
    let category: String
}

struct ContentView: View {
    @StateObject private var viewModel = PromptViewModel()
    @State private var showingNewPromptSheet = false
    @State private var selectedPromptID: UUID?
    @State private var showingAddCategoryAlert = false
    @State private var newCategoryName = ""
    @State private var selectedPrompt: Prompt? = nil
    @State private var selectedCategoryForSheet: CategorySheetItem? = nil // For category navigation
    @State private var selectedTab: Int = 0 // For TabView
    @State private var favMostUsedSegment: Int = 0 // 0: Favorites, 1: Most Used
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        #if os(iOS)
        ZStack {
            // Gradient background for the whole app
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.listBackground.blend(with: AppColors.primary, fraction: 0.25),
                    AppColors.secondary.blend(with: AppColors.primary, fraction: 0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(spacing: 0) {
                // App Title
                Text("Prompt Buddy")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.primary)
                    .padding(.top, 18)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
                Divider()
                // Tab Content
                TabView(selection: $selectedTab) {
                    // All Prompts Tab
                    ZStack {
                        Color.clear.background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.listBackground.blend(with: AppColors.primary, fraction: 0.25),
                                    AppColors.secondary.blend(with: AppColors.primary, fraction: 0.15)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        VStack(spacing: 0) {
                            AllPromptsSectionView(viewModel: viewModel) { prompt in
                                selectedPrompt = prompt
                                selectedPromptID = prompt.id
                                viewModel.incrementUsage(for: prompt)
                            }
                            .frame(maxWidth: 600)
                            .padding(.top, 24)
                            .padding(.horizontal, 12)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    .tabItem {
                        Image(systemName: "list.bullet.rectangle")
                        Text("All Prompts")
                    }
                    .tag(0)
                    // Categories Tab
                    ZStack {
                        Color.clear.background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.listBackground.blend(with: AppColors.primary, fraction: 0.25),
                                    AppColors.secondary.blend(with: AppColors.primary, fraction: 0.15)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        VStack(spacing: 0) {
                            GlassSection(title: "Categories", systemImage: "folder.fill", trailingHeader: {
                                Button(action: { showingAddCategoryAlert = true }) {
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
                            }) {
                                ScrollView {
                                    VStack(spacing: 0) {
                                        ForEach(viewModel.categories, id: \.self) { category in
                                            CategoryRowView(
                                                category: category,
                                                isSelected: viewModel.selectedCategory == category,
                                                onTap: {
                                                    selectedCategoryForSheet = CategorySheetItem(category: category)
                                                },
                                                onDelete: {
                                                    // Show delete alert logic here
                                                    // (keep as in your current implementation)
                                                    // ...
                                                }
                                            )
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: 600)
                            .padding(.top, 24)
                            .padding(.horizontal, 12)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    .tabItem {
                        Image(systemName: "folder")
                        Text("Categories")
                    }
                    .tag(1)
                    // Add Prompt (center, floating)
                    Color.clear
                        .tabItem {
                            ZStack {
                                Circle()
                                    .fill(AppColors.button)
                                    .frame(width: 56, height: 56)
                                    .shadow(radius: 8)
                                Image(systemName: "plus")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .onAppear { showingNewPromptSheet = true }
                        .tag(2)
                    // My Prompts Tab
                    ZStack {
                        Color.clear.background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.listBackground.blend(with: AppColors.primary, fraction: 0.25),
                                    AppColors.secondary.blend(with: AppColors.primary, fraction: 0.15)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        VStack(spacing: 0) {
                            GlassSection(title: "My Prompts", systemImage: "star.fill") {
                                VStack(spacing: 0) {
                                    HStack {
                                        Spacer()
                                        Picker("Favorites or Most Used", selection: $favMostUsedSegment) {
                                            Text("Favorites").tag(0)
                                            Text("Most Used").tag(1)
                                        }
                                        .pickerStyle(SegmentedPickerStyle())
                                        .padding(6)
                                        .background(Color.white.opacity(0.18))
                                        .clipShape(Capsule())
                                        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                                        .padding(.horizontal, 16)
                                        Spacer()
                                    }
                                    .padding(.top, 8)
                                    ScrollView {
                                        VStack(spacing: 0) {
                                            if favMostUsedSegment == 0 {
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
                                                if viewModel.favoritePrompts.isEmpty {
                                                    Text("No favorites yet.")
                                                        .foregroundStyle(.secondary)
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                        .padding(.vertical, 16)
                                                }
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
                                                if viewModel.mostUsedPrompts.isEmpty {
                                                    Text("No prompts yet.")
                                                        .foregroundStyle(.secondary)
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                        .padding(.vertical, 16)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: 600)
                            .padding(.top, 24)
                            .padding(.horizontal, 12)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    .tabItem {
                        Image(systemName: "star.fill")
                        Text("My Prompts")
                    }
                    .tag(3)
                    // Profile Tab
                    ZStack {
                        Color.clear.background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.listBackground.blend(with: AppColors.primary, fraction: 0.25),
                                    AppColors.secondary.blend(with: AppColors.primary, fraction: 0.15)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        VStack {
                            ProfileView()
                                .frame(maxWidth: 600)
                                .padding(.top, 24)
                                .padding(.horizontal, 12)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    .tag(4)
                }
            }
            // Floating Add Prompt Button (centered above tab bar)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingNewPromptSheet = true }) {
                        ZStack {
                            Circle()
                                .fill(AppColors.button)
                                .frame(width: 68, height: 68)
                                .shadow(radius: 12)
                            Image(systemName: "plus")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .accessibilityLabel("Add Prompt")
                    .offset(y: -38)
                    Spacer()
                }
            }
            .allowsHitTesting(false)
            .ignoresSafeArea()
            // Make the button hit-testable
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingNewPromptSheet = true }) {
                        Color.clear.frame(width: 68, height: 68)
                    }
                    .offset(y: -38)
                    Spacer()
                }
            }
            .background(Color.clear)
        }
        .sheet(isPresented: $showingNewPromptSheet) {
            NewPromptView(viewModel: viewModel)
        }
        .sheet(item: $selectedPrompt) { prompt in
            PromptDetailView(promptID: prompt.id, viewModel: viewModel)
        }
        .sheet(item: $selectedCategoryForSheet) { item in
            CategoryPromptsListView(category: item.category, viewModel: viewModel) { prompt in
                selectedPrompt = prompt
            }
        }
        #else
        // macOS or other platforms: keep the old layout
        // ... existing code ...
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.listBackground.blend(with: AppColors.primary, fraction: 0.25),
                    AppColors.secondary.blend(with: AppColors.primary, fraction: 0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    FavoritesSectionView(viewModel: viewModel) { prompt in
                        selectedPrompt = prompt
                        selectedPromptID = prompt.id
                        viewModel.incrementUsage(for: prompt)
                    }
                    MostUsedSectionView(viewModel: viewModel) { prompt in
                        selectedPrompt = prompt
                        selectedPromptID = prompt.id
                        viewModel.incrementUsage(for: prompt)
                    }
                    CategoriesSectionView(
                        viewModel: viewModel,
                        showingAddCategoryAlert: $showingAddCategoryAlert,
                        newCategoryName: $newCategoryName,
                        onCategoryTap: { category in
                            selectedCategoryForSheet = CategorySheetItem(category: category)
                        }
                    )
                    AllPromptsSectionView(viewModel: viewModel) { prompt in
                        selectedPrompt = prompt
                        selectedPromptID = prompt.id
                        viewModel.incrementUsage(for: prompt)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 32)
                .padding(.bottom, 16)
            }
        }
        .sheet(isPresented: $showingNewPromptSheet) {
            NewPromptView(viewModel: viewModel)
        }
        .sheet(item: $selectedPrompt) { prompt in
            PromptDetailView(promptID: prompt.id, viewModel: viewModel)
        }
        .sheet(item: $selectedCategoryForSheet) { item in
            CategoryPromptsListView(category: item.category, viewModel: viewModel) { prompt in
                selectedPrompt = prompt
            }
        }
        #endif
    }
}

// MARK: - Favorites Section View
/// Displays the user's favorite prompts in a glassmorphic section.
/// Tapping a prompt opens its details.
struct FavoritesSectionView: View {
    @ObservedObject var viewModel: PromptViewModel
    var onPromptTap: (Prompt) -> Void
    var body: some View {
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
                        onPromptTap(prompt)
                    }
                }
            }
        }
    }
}

// MARK: - Most Used Section View
/// Displays the most used prompts in a glassmorphic section.
/// Includes a reset usage button aligned with the header.
struct MostUsedSectionView: View {
    @ObservedObject var viewModel: PromptViewModel
    var onPromptTap: (Prompt) -> Void
    var body: some View {
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
                    MostUsedPromptRowView(prompt: prompt, onTap: { onPromptTap(prompt) })
                }
            }
        }
    }
}

/// Row view for a single most used prompt.
struct MostUsedPromptRowView: View {
    let prompt: Prompt
    let onTap: () -> Void
    var body: some View {
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
        .onTapGesture { onTap() }
    }
}

// MARK: - Categories Section View
/// Displays all categories in a glassmorphic section.
/// Tapping a category opens a sheet with all prompts in that category.
struct CategoriesSectionView: View {
    @ObservedObject var viewModel: PromptViewModel
    @Binding var showingAddCategoryAlert: Bool
    @Binding var newCategoryName: String
    var onCategoryTap: (String) -> Void
    @State private var categoryToDelete: String? = nil
    @State private var showDeleteAlert = false
    var body: some View {
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
                CategoryRowView(
                    category: category,
                    isSelected: viewModel.selectedCategory == category,
                    onTap: {
                        onCategoryTap(category)
                    },
                    onDelete: {
                        categoryToDelete = category
                        showDeleteAlert = true
                    }
                )
            }
        }
        // Delete confirmation alert
        .alert("Delete Category?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let cat = categoryToDelete {
                    viewModel.deleteCategoryAndPrompts(cat)
                }
                categoryToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                categoryToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this category and all its prompts? This action cannot be undone.")
        }
    }
}

/// Row view for a single category, with delete button.
struct CategoryRowView: View {
    let category: String
    let isSelected: Bool
    let onTap: () -> Void
    var onDelete: (() -> Void)? = nil
    var body: some View {
        GlassListItem {
            HStack {
                Text(category)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(isSelected ? .accentColor : .primary)
                if let onDelete = onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onTapGesture { onTap() }
        .background(
            isSelected ?
                AnyView(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.accentColor.opacity(0.08))
                )
                : AnyView(Color.clear)
        )
    }
}

// MARK: - Category Prompts List View
/// Shows all prompts in a selected category. Tapping a prompt opens its details.
struct CategoryPromptsListView: View, Identifiable {
    let id = UUID() // For .sheet(item:)
    let category: String
    @ObservedObject var viewModel: PromptViewModel
    var onPromptTap: (Prompt) -> Void
    var body: some View {
        ZStack {
            // App background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.listBackground.blend(with: AppColors.primary, fraction: 0.25),
                    AppColors.secondary.blend(with: AppColors.primary, fraction: 0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Centered VStack for header and card
            VStack(spacing: 0) {
                // Section header with icon
                HStack(spacing: 10) {
                    Image(systemName: "tag.fill")
                        .foregroundColor(AppColors.secondary)
                    Text(category)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primary)
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
                
                // Glassmorphic card for the list, always centered and with max width
                ZStack {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(AppColors.listBackground.opacity(0.95))
                        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
                    VStack {
                        if viewModel.prompts.filter({ $0.category == category }).isEmpty {
                            Text("No prompts in this category.")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 32)
                        } else {
                            ScrollView {
                                VStack(spacing: 16) { // Fixed vertical spacing
                                    ForEach(viewModel.prompts.filter { $0.category == category }) { prompt in
                                        GlassListItem {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(prompt.name)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(AppColors.label)
                                                    .multilineTextAlignment(.leading)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                Text(prompt.content)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.leading)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            .frame(width: 340, height: 70, alignment: .leading) // Fixed size
                                        }
                                        .onTapGesture { onPromptTap(prompt) }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    .frame(minHeight: 250)
                }
                .frame(maxWidth: 500)
                .padding(.horizontal, 8)
                .padding(.vertical, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        // Dynamic sheet sizing for iOS 16+
        .ifAvailableiOS16 { view in
            view.presentationDetents([.medium, .large])
        }
    }
}

// MARK: - All Prompts Section View
/// Displays all prompts in the app, regardless of category, with the category name shown on the right.
/// Tapping a prompt opens its details. Includes a reactive search bar.

/// Row view for a single prompt in the All Prompts section, showing the category name on the right.
struct AllPromptsRowView: View {
    let prompt: Prompt
    let onTap: () -> Void
    var body: some View {
        GlassListItem {
            HStack {
                Text(prompt.name)
                    .fontWeight(.medium)
                Spacer()
                Text(prompt.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onTapGesture { onTap() }
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
                    #if os(macOS)
                    Image(systemName: systemImage)
                        .foregroundColor(.accentColor)
                        .font(.system(size: 28, weight: .bold))
                    #else
                    Image(systemName: systemImage)
                        .foregroundColor(.accentColor)
                .font(.headline)
                    #endif
                }
                #if os(macOS)
                Text(title.uppercased())
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.secondary)
                #else
                Text(title.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                #endif
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

// MARK: - Profile View (for Profile tab)
struct ProfileView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 32)
            // App logo or avatar
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                )
            // Name
            Text("Your Name")
                .font(.title2)
                .fontWeight(.bold)
            // Update Password Button
            Button(action: {
                // Implement update password action
            }) {
                Text("Update Password")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(AppColors.button)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 
