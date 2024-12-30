import SwiftUI
import Charts
import CoreData

struct StatisticsView: View {
    @StateObject private var viewModel: StatisticsViewModel
    
    init(viewContext: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(viewContext: viewContext))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Total Statistics Card
                TotalStatsCard(viewModel: viewModel)
                    .padding(.horizontal)
                
                // Completion Distribution Chart
                CompletionPieChart(zikirs: viewModel.zikirs)
                    .frame(height: 250)
                    .padding(.horizontal)
                
                // Weekly Progress Chart
                WeeklyProgressChart(weeklyData: viewModel.weeklyData)
                    .frame(height: 250)
                    .padding(.horizontal)
                
                // Individual Zikir Stats
                ForEach(viewModel.zikirs) { zikir in
                    ZikirStatsCard(zikir: zikir)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(LocalizedStringKey("statistics"))
    }
}

struct CompletionPieChart: View {
    let zikirs: [Zikir]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(LocalizedStringKey("dhikr_distribution"))
                .font(.headline)
                .padding(.bottom, 4)
            
            Chart {
                ForEach(zikirs) { zikir in
                    SectorMark(
                        angle: .value("Tamamlama", zikir.completions),
                        innerRadius: .ratio(0.618),
                        angularInset: 1.5
                    )
                    .cornerRadius(5)
                    .foregroundStyle(by: .value("Zikir", zikir.name))
                }
            }
            .chartLegend(position: .bottom, spacing: 20)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct WeeklyProgressChart: View {
    let weeklyData: [(date: Date, count: Int)]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(LocalizedStringKey("weekly_progress"))
                .font(.headline)
                .padding(.bottom, 4)
            
            Chart {
                ForEach(weeklyData, id: \.date) { item in
                    BarMark(
                        x: .value("Gün", item.date, unit: .day),
                        y: .value("Tamamlama", item.count)
                    )
                    .foregroundStyle(Color.orange.gradient)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct TotalStatsCard: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(LocalizedStringKey("total_statistics"))
                .font(.headline)
            
            HStack {
                StatBox(title: LocalizedStringKey("total_completions"), value: "\(viewModel.totalCompletions)")
                Divider()
                StatBox(title: LocalizedStringKey("total_dhikr"), value: "\(viewModel.totalZikirs)")
            }
            
            if let mostCompleted = viewModel.mostCompletedZikir {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizedStringKey("most_completed"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(mostCompleted.name)
                        .font(.headline)
                    Text("\(mostCompleted.completions) \(String(localized: "times"))")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ZikirStatsCard: View {
    @ObservedObject var zikir: Zikir
    
    var lastCompletedText: String {
        if let date = zikir.lastCompletedDate {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return formatter.localizedString(for: date, relativeTo: Date())
        }
        return String(localized: "not_completed_yet")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(zikir.name)
                .font(.headline)
            
            HStack {
                StatBox(title: LocalizedStringKey("target"), value: "\(zikir.targetCount)")
                Divider()
                StatBox(title: LocalizedStringKey("current"), value: "\(zikir.count)")
                Divider()
                StatBox(title: LocalizedStringKey("completions"), value: "\(zikir.completions)")
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizedStringKey("last_completion"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(lastCompletedText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct StatBox: View {
    let title: LocalizedStringKey
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .bold()
        }
        .frame(maxWidth: .infinity)
    }
}
