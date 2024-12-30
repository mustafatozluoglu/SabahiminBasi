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
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            // Zikirler Tab
            NavigationView {
                List {
                    ForEach(zikirs) { zikir in
                        NavigationLink(destination: makeDetailView(for: zikir)) {
                            ZikirRowView(zikir: zikir)
                        }
                    }
                    .onDelete(perform: deleteZikirs)
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
                .navigationTitle(LocalizedStringKey("dhikr_list"))
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
                    .navigationTitle(LocalizedStringKey("settings"))
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
