import Foundation
import CoreData
import Combine

class StatisticsViewModel: ObservableObject {
    @Published var zikirs: [Zikir] = []
    private var viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        fetchZikirs()
        setupObserver()
    }
    
    private func setupObserver() {
        NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave, object: viewContext)
            .sink { [weak self] _ in
                self?.fetchZikirs()
            }
            .store(in: &cancellables)
    }
    
    private func fetchZikirs() {
        let request = NSFetchRequest<Zikir>(entityName: "Zikir")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Zikir.createdAt, ascending: true)]
        
        do {
            zikirs = try viewContext.fetch(request)
            objectWillChange.send()
        } catch {
            print("Error fetching zikirs: \(error)")
        }
    }
    
    var totalCompletions: Int {
        zikirs.reduce(0) { $0 + Int($1.completions) }
    }
    
    var totalZikirs: Int {
        zikirs.count
    }
    
    var mostCompletedZikir: Zikir? {
        zikirs.max(by: { $0.completions < $1.completions })
    }
    
    var weeklyData: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let today = Date()
        let weekDates = (0..<7).map { days in
            calendar.date(byAdding: .day, value: -days, to: today)!
        }.reversed()
        
        return weekDates.map { date in
            let dailyCount = zikirs.reduce(0) { sum, zikir in
                if let lastCompleted = zikir.lastCompletedDate,
                   calendar.isDate(lastCompleted, inSameDayAs: date) {
                    return sum + Int(zikir.completions)
                }
                return sum
            }
            return (date: date, count: dailyCount)
        }
    }
}
