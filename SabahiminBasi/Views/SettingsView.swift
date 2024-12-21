import SwiftUI
import MessageUI

struct SettingsView: View {
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("timerInterval") private var timerInterval: Double = 1.0
    @AppStorage("timerEnabled") private var timerEnabled: Bool = false
    @State private var showingMailCompose = false
    @State private var mailComposeResult: Result<MFMailComposeResult, Error>? = nil
    @State private var showingSuccessAlert = false
    
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
                
                Button("Geri Bildirim Gönder") {
                    showingMailCompose = true
                }
            }
            .navigationTitle("Ayarlar")
            .alert(isPresented: $showingSuccessAlert) {
                Alert(
                    title: Text("Başarılı"),
                    message: Text("Geri bildiriminiz için teşekkür ederiz!"),
                    dismissButton: .default(Text("Tamam"))
                )
            }
            .sheet(isPresented: $showingMailCompose) {
                MailComposeView(isShowing: $showingMailCompose, result: $mailComposeResult, showingSuccessAlert: $showingSuccessAlert)
            }
        }
    }
}

struct MailComposeView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?
    @Binding var showingSuccessAlert: Bool
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?
        @Binding var showingSuccessAlert: Bool
        
        init(isShowing: Binding<Bool>, result: Binding<Result<MFMailComposeResult, Error>?>, showingSuccessAlert: Binding<Bool>) {
            _isShowing = isShowing
            _result = result
            _showingSuccessAlert = showingSuccessAlert
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer {
                isShowing = false
            }
            if let error = error {
                self.result = .failure(error)
                return
            }
            self.result = .success(result)
            if result == .sent {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showingSuccessAlert = true
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing, result: $result, showingSuccessAlert: $showingSuccessAlert)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailComposeView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(["m_saidt@hotmail.com"])
        vc.setSubject("Zikir Uygulaması Geri Bildirim")
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailComposeView>) {}
}

#Preview {
    SettingsView()
}
