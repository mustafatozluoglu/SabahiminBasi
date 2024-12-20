import SwiftUI


@main
struct ZikirCounterApp: App {
    let repository: ZikirRepository
    let viewModel: ZikirListViewModel
    
    init() {
        let storageService = UserDefaultsStorageService()
        repository = DefaultZikirRepository(storageService: storageService)
        viewModel = ZikirListViewModel(repository: repository)
    }
    
    var body: some Scene {
        WindowGroup {
            ZikirListView(viewModel: viewModel)
        }
    }
}
