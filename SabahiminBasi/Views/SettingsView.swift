import SwiftUI

struct SettingsView: View {
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Genel")) {
                    Toggle("Titreşimli Geri Bildirim", isOn: $hapticFeedbackEnabled)
                }
            }
            .navigationTitle("Ayarlar")
        }
    }
}

#Preview {
    SettingsView()
}
