import SwiftUI
import CoreData

public struct ZikirListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Zikir.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Zikir.createdAt, ascending: true)],
        animation: .default
    ) private var zikirs: FetchedResults<Zikir>
    @State private var showingAddZikir = false
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    
    var filteredZikirs: [Zikir] {
        zikirs.filter { zikir in
            let matchesSearch = searchText.isEmpty || 
                zikir.name.localizedCaseInsensitiveContains(searchText) ||
                zikir.zikirDescription.localizedCaseInsensitiveContains(searchText)
            let matchesFavorite = !showFavoritesOnly || zikir.favorite
            return matchesSearch && matchesFavorite
        }
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            // Zikirler Tab
            NavigationView {
                Group {
                    if zikirs.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text(LocalizedStringKey("add_first_zikir"))
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            
                            Text(LocalizedStringKey("add_first_zikir_description"))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: { showingAddZikir = true }) {
                                Label(LocalizedStringKey("add_dhikr"), systemImage: "plus")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.top)
                        }
                        .padding()
                    } else {
                        List {
                            SearchBar(text: $searchText)
                                .listRowInsets(EdgeInsets())
                            
                            Toggle(isOn: $showFavoritesOnly) {
                                Label(LocalizedStringKey("show_favorites_only"), systemImage: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                            
                            ForEach(filteredZikirs) { zikir in
                                NavigationLink(destination: makeDetailView(for: zikir)) {
                                    ZikirRowView(zikir: zikir)
                                }
                            }
                            .onDelete(perform: deleteZikirs)
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddZikir = true }) {
                            Label(LocalizedStringKey("add_dhikr"), systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddZikir) {
                    AddZikirView { name, description, targetCount in
                        addZikir(name: name, description: description, targetCount: targetCount)
                    }
                }
                //.navigationTitle(LocalizedStringKey("dhikr_list"))
            }
            .tabItem {
                Label(LocalizedStringKey("dhikrs"), systemImage: "list.bullet")
            }
            .tag(0)
            
            // İstatistikler Tab
            NavigationView {
                StatisticsView(viewContext: viewContext)
            }
            .tabItem {
                Label(LocalizedStringKey("statistics"), systemImage: "chart.bar.fill")
            }
            .tag(1)
            
            // Ayarlar Tab
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label(LocalizedStringKey("settings"), systemImage: "gear")
            }
            .tag(2)
        }
    }
    
    private func makeDetailView(for zikir: Zikir) -> some View {
        ZikirDetailView(viewModel: ZikirDetailViewModel(zikir: zikir, viewContext: viewContext))
    }
    
    private func deleteZikirs(offsets: IndexSet) {
        withAnimation {
            offsets.map { zikirs[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func addZikir(name: String, description: String, targetCount: Int) {
        let newZikir = Zikir(context: viewContext)
        newZikir.id = UUID()
        newZikir.name = name
        newZikir.zikirDescription = description
        newZikir.targetCount = Int32(targetCount)
        newZikir.count = 0
        newZikir.completions = 0
        newZikir.createdAt = Date()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Error saving context: \(nsError), \(nsError.userInfo)")
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(LocalizedStringKey("search_zikirs"), text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
