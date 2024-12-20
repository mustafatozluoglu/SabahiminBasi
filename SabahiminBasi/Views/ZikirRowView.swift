import SwiftUI

public struct ZikirRowView: View {
    let zikir: Zikir
    
    public var body: some View {
        HStack {
            VStack(alignment: .center) {
                Text("\(formatNumber(zikir.targetCount))")
                    .font(.title2)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("\(formatNumber(zikir.count))")
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(width: 50)
            .padding(8)
            .background(Color.gray)
            .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(zikir.name)
                    .font(.headline)
                Text(zikir.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("\(zikir.completions). kez tamamlandı.")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatNumber(_ number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
