import SwiftUI

public struct ZikirListView: View {
    @StateObject private var viewModel: ZikirListViewModel
    @State private var showingAddZikir = false
    
    public init(viewModel: ZikirListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
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
            .navigationTitle("My List")
            .toolbar {
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
        }
        .onAppear {
            viewModel.load()
        }
    }
    
    private func makeDetailView(for zikir: Zikir) -> some View {
        let detailViewModel = ZikirDetailViewModel(zikir: zikir, repository: viewModel.repository)
        return ZikirDetailView(viewModel: detailViewModel)
    }
}
