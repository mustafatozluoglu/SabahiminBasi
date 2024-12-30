import SwiftUI

public struct ZikirRowView: View {
    let zikir: Zikir
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(zikir.name ?? "")
                .font(.headline)
            
            HStack {
                Text(String(format: String(localized: "completion_progress_format"), zikir.count, zikir.targetCount))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(String(format: String(localized: "completion_count_format"), zikir.completions))
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            ProgressView(value: Double(zikir.count), total: Double(zikir.targetCount))
                .progressViewStyle(LinearProgressViewStyle())
                .tint(progressColor)
        }
        .padding(.vertical, 4)
    }
    
    private var progressColor: Color {
        let progress = Double(zikir.count) / Double(zikir.targetCount)
        if progress >= 1.0 {
            return .green
        } else if progress >= 0.5 {
            return .orange
        } else {
            return .blue
        }
    }
}
