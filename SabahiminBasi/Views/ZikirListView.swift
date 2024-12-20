import SwiftUI

public struct ZikirListView: View {
    @StateObject private var viewModel: ZikirListViewModel
    @State private var showingAddZikir = false
    @State private var showingSettings = false
    
    public init(viewModel: ZikirListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            NavigationView {
                List {
                    ForEach(viewModel.zikirs) { zikir in
                        NavigationLink(destination: makeDetailView(for: zikir)) {
                            ZikirRowView(zikir: zikir)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            viewModel.delete(viewModel.zikirs[index])
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape.fill")
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("Zikir Listem")
                                .font(.headline)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddZikir = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddZikir) {
                    AddZikirView { name, description, targetCount in
                        viewModel.add(name: name, description: description, targetCount: targetCount)
                    }
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
            }
            .onAppear {
                viewModel.load()
            }
        }
    }
    
    private func makeDetailView(for zikir: Zikir) -> some View {
        let detailViewModel = ZikirDetailViewModel(zikir: zikir, repository: viewModel.repository)
        return ZikirDetailView(viewModel: detailViewModel)
    }
}
