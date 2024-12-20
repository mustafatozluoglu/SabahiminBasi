import SwiftUI

public struct ZikirRowView: View {
    let zikir: Zikir
    
    public var body: some View {
        HStack {
            VStack(alignment: .center) {
                Text("\(zikir.targetCount)")
                    .font(.title2)
                    .foregroundColor(.white)
                Text("\(zikir.count)")
                    .font(.caption)
                    .foregroundColor(.white)
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
}
