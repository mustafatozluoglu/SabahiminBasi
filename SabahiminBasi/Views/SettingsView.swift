import SwiftUI

struct SettingsView: View {
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("timerInterval") private var timerInterval: Double = 1.0
    @AppStorage("timerEnabled") private var timerEnabled: Bool = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Genel")) {
                    Toggle("Titreşimli Geri Bildirim", isOn: $hapticFeedbackEnabled)
                    
                    Toggle("Zamanlayıcı Etkin", isOn: $timerEnabled)
                    
                    if timerEnabled {
                        HStack {
                            Text("Zamanlayıcı Aralığı")
                            Spacer()
                            Text("\(timerInterval, specifier: "%.1f") saniye")
                        }
                        
                        Slider(value: $timerInterval, in: 0.1...30.0, step: 0.1) {
                            Text("Zamanlayıcı Aralığı")
                        }
                    }
                }
            }
            .navigationTitle("Ayarlar")
        }
    }
}

#Preview {
    SettingsView()
}
