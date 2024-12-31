import SwiftUI
import CoreData
import Combine

struct ZikirRowView: View {
    @ObservedObject var zikir: Zikir
    @Environment(\.managedObjectContext) private var viewContext
    
    private let categoryColors: [String: Color] = [
        "morning": .blue,
        "evening": .purple,
        "daily": .green,
        "special": .orange,
        "custom": .gray
    ]
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(zikir.name)
                        .font(.headline)
                    
                    if zikir.favorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 14))
                    }
                }
                
                Text(zikir.zikirDescription)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                if let category = zikir.category {
                    HStack(spacing: 4) {
                        Image(systemName: category.icon)
                            .font(.system(size: 12))
                        Text("\(category.name)")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(categoryColors[category.type] ?? .gray)
                    )
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(zikir.count)/\(zikir.targetCount)")
                    .font(.system(size: 14, weight: .medium))
                
                Text("\(zikir.completions) \(String(localized: "times"))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
            viewContext.refresh(zikir, mergeChanges: true)
        }
    }
}
