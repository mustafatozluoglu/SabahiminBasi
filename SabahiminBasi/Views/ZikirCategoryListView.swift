import SwiftUI
import CoreData

struct ZikirCategoryListView: View {
    @StateObject private var viewModel: ZikirCategoryViewModel
    @State private var showingAddCategory = false
    @State private var searchText = ""
    
    init(viewContext: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: ZikirCategoryViewModel(viewContext: viewContext))
    }
    
    var filteredCategories: [ZikirCategory] {
        if searchText.isEmpty {
            return viewModel.categories
        }
        return viewModel.categories.filter { category in
            category.name.localizedCaseInsensitiveContains(searchText) ||
            category.categoryDescription.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List {
            SearchBar(text: $searchText)
                .listRowInsets(EdgeInsets())
            
            ForEach(filteredCategories) { category in
                NavigationLink(destination: CategoryDetailView(category: category)) {
                    CategoryRowView(category: category)
                }
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    viewModel.deleteCategory(filteredCategories[index])
                }
            }
        }
        .navigationTitle(LocalizedStringKey("categories"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddCategory = true }) {
                    Label(LocalizedStringKey("add_category"), systemImage: "folder.badge.plus")
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView(viewModel: viewModel)
        }
    }
}

struct CategoryRowView: View {
    let category: ZikirCategory
    
    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .foregroundColor(.blue)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text(category.name)
                    .font(.headline)
                
                Text(category.categoryDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(category.zikirArray.count) \(String(localized: "dhikrs"))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ZikirCategoryViewModel
    @State private var name = ""
    @State private var description = ""
    @State private var selectedType = "custom"
    @State private var selectedIcon = "folder.fill"
    
    private let types = [
        "morning": String(localized: "morning"),
        "evening": String(localized: "evening"),
        "daily": String(localized: "daily"),
        "special": String(localized: "special"),
        "custom": String(localized: "custom")
    ]
    
    private let icons = [
        "folder.fill",
        "star.fill",
        "heart.fill",
        "sun.max.fill",
        "moon.fill",
        "clock.fill",
        "bookmark.fill",
        "tag.fill"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(LocalizedStringKey("category_details"))) {
                    TextField(LocalizedStringKey("category_name"), text: $name)
                    TextField(LocalizedStringKey("category_description"), text: $description)
                    
                    Picker(LocalizedStringKey("category_type"), selection: $selectedType) {
                        ForEach(Array(types.keys), id: \.self) { key in
                            Text(LocalizedStringKey(types[key] ?? key))
                                .tag(key)
                        }
                    }
                }
                
                Section(header: Text(LocalizedStringKey("category_icon"))) {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 60))
                    ], spacing: 20) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title)
                                .foregroundColor(selectedIcon == icon ? .blue : .gray)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.clear)
                                )
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle(LocalizedStringKey("new_category"))
            .navigationBarItems(
                leading: Button(LocalizedStringKey("cancel")) {
                    dismiss()
                },
                trailing: Button(LocalizedStringKey("save")) {
                    viewModel.createCategory(
                        name: name,
                        description: description,
                        type: selectedType,
                        icon: selectedIcon
                    )
                    dismiss()
                }
                .disabled(name.isEmpty)
            )
        }
    }
}

struct CategoryDetailView: View {
    let category: ZikirCategory
    
    var body: some View {
        List {
            Section(header: Text(LocalizedStringKey("category_info"))) {
                LabeledContent(LocalizedStringKey("type")) {
                    Text(LocalizedStringKey(category.type))
                }
                
                if !category.categoryDescription.isEmpty {
                    Text(category.categoryDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text(LocalizedStringKey("dhikrs"))) {
                if category.zikirArray.isEmpty {
                    Text(LocalizedStringKey("no_dhikrs_in_category"))
                        .foregroundColor(.secondary)
                } else {
                    ForEach(category.zikirArray) { zikir in
                        ZikirRowView(zikir: zikir)
                    }
                }
            }
        }
        .navigationTitle(category.name)
    }
} 