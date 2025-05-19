import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var viewModel = PromptViewModel()
    @State private var showingNewPromptSheet = false
    @State private var selectedPromptID: UUID?
    @State private var showingAddCategoryAlert = false
    @State private var newCategoryName = ""
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            VStack(spacing: 0) {
                // Most Used Section
                List {
                    Section(header:
                        HStack {
                            Text("Most Used")
                            Spacer()
                            Button(action: {
                                viewModel.resetAllUsage()
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .imageScale(.small)
                            }
                            .buttonStyle(.plain)
                            .help("Reset usage counts")
                        }
                    ) {
                        ForEach(viewModel.mostUsedPrompts, id: \.id) { prompt in
                            Button(action: {
                                selectedPromptID = prompt.id
                                viewModel.incrementUsage(for: prompt)
                            }) {
                                HStack {
                                    Text(prompt.name)
                                    Spacer()
                                    if prompt.usageCount > 0 {
                                        Text("\(prompt.usageCount)")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .listStyle(.sidebar)
                .frame(maxHeight: 300) // Adjust as needed for iOS/macOS
                // Categories Section
                VStack(spacing: 0) {
                    HStack {
                        Text("Categories")
                            .font(.headline)
                            .padding(.leading, 8)
                        Spacer()
                        Button(action: {
                            showingAddCategoryAlert = true
                        }) {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(.borderless)
                        .padding(.trailing, 8)
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
                    .padding(.vertical, 8)
                    List(selection: $viewModel.selectedCategory) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category)
                                .tag(Optional(category))
                        }
                    }
                    .listStyle(.sidebar)
                }
            }
            .frame(minWidth: 200)
        } content: {
            // Prompt List
            List(viewModel.filteredPrompts, selection: $selectedPromptID) { prompt in
                PromptRowView(prompt: prompt)
                    .tag(prompt.id)
                    .onTapGesture {
                        selectedPromptID = prompt.id
                        viewModel.incrementUsage(for: prompt)
                    }
                    .contextMenu {
                        Button("Duplicate") {
                            viewModel.duplicatePrompt(prompt)
                        }
                        Button("Delete", role: .destructive) {
                            viewModel.deletePrompt(prompt)
                        }
                    }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search prompts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Picker("Sort By", selection: $viewModel.sortOrder) {
                            Text("Name").tag(PromptViewModel.SortOrder.name)
                            Text("Date Created").tag(PromptViewModel.SortOrder.dateCreated)
                            Text("Date Updated").tag(PromptViewModel.SortOrder.dateUpdated)
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewPromptSheet = true
                    } label: {
                        Label("New Prompt", systemImage: "plus")
                    }
                }
            }
        } detail: {
            if let selectedID = selectedPromptID {
                PromptDetailView(promptID: selectedID, viewModel: viewModel)
            } else {
                Text("Select a prompt")
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showingNewPromptSheet) {
            NewPromptView(viewModel: viewModel)
        }
    }
}

struct PromptRowView: View {
    let prompt: Prompt
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(prompt.name)
                .font(.headline)
            Text(prompt.content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 