import SwiftUI

struct ZikirRowView: View {
    let zikir: Zikir
    
    var body: some View {
        HStack {
            Text("\(zikir.count)")
                .font(.title2)
                .frame(width: 50)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.gray)
                .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(zikir.name)
                    .font(.headline)
                Text(zikir.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}
