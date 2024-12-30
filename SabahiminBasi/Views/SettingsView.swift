import SwiftUI
import MessageUI
import UserNotifications

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("timerEnabled") private var timerEnabled = false
    @AppStorage("timerInterval") private var timerInterval = 1.0
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("selectedLanguage") private var selectedLanguage = "en"
    @State private var showingMailCompose = false
    @State private var showingSuccessAlert = false
    @Environment(\.colorScheme) var colorScheme
    
    private let languages = [
        "en": "English",
        "tr": "Türkçe"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(LocalizedStringKey("general"))) {
                    Toggle(LocalizedStringKey("dark_mode"), isOn: $isDarkMode)
                        .onChange(of: isDarkMode) { newValue in
                            setAppearance(newValue)
                        }
                    
                    Picker(selection: $selectedLanguage) {
                        ForEach(languages.sorted(by: { $0.value < $1.value }), id: \.key) { key, value in
                            Text(value).tag(key)
                        }
                    } label: {
                        Text(LocalizedStringKey("language"))
                    }
                    .onChange(of: selectedLanguage) { _ in
                        UserDefaults.standard.set([selectedLanguage], forKey: "AppleLanguages")
                        UserDefaults.standard.synchronize()
                    }
                    
                    Toggle(LocalizedStringKey("haptic_feedback"), isOn: $hapticFeedbackEnabled)
                }
                
                Section(header: Text(LocalizedStringKey("timer"))) {
                    Toggle(LocalizedStringKey("timer_enabled"), isOn: $timerEnabled)
                    
                    if timerEnabled {
                        HStack {
                            Text(LocalizedStringKey("interval"))
                            Spacer()
                            Text(String(format: "%.1f", timerInterval))
                        }
                        
                        Slider(value: $timerInterval, in: 0.1...30.0, step: 0.1)
                    }
                }
                
                Section(header: Text(LocalizedStringKey("notifications"))) {
                    Toggle(LocalizedStringKey("notifications_enabled"), isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { newValue in
                            if newValue {
                                requestNotificationPermission()
                            }
                        }
                }
                
                Section(header: Text(LocalizedStringKey("about"))) {
                    Button(action: {
                        showingMailCompose = true
                    }) {
                        Text(LocalizedStringKey("send_feedback"))
                    }
                    
                    HStack {
                        Text(LocalizedStringKey("version"))
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("settings"))
            .alert(String(localized: "success"), isPresented: $showingSuccessAlert) {
                Button(String(localized: "ok")) {}
            } message: {
                Text(LocalizedStringKey("feedback_sent"))
            }
            .sheet(isPresented: $showingMailCompose) {
                MailComposeView(isShowing: $showingMailCompose, showSuccessAlert: $showingSuccessAlert)
            }
        }
        .onAppear {
            // Ensure the UI matches the stored dark mode setting
            setAppearance(isDarkMode)
        }
    }
    
    private func setAppearance(_ isDark: Bool) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = isDark ? .dark : .light
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
}

struct MailComposeView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    @Binding var showSuccessAlert: Bool
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool
        @Binding var showSuccessAlert: Bool
        
        init(isShowing: Binding<Bool>, showSuccessAlert: Binding<Bool>) {
            _isShowing = isShowing
            _showSuccessAlert = showSuccessAlert
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                 didFinishWith result: MFMailComposeResult,
                                 error: Error?) {
            isShowing = false
            if result == .sent {
                showSuccessAlert = true
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing, showSuccessAlert: $showSuccessAlert)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["m_saidt@hotmail.com"])
        vc.setSubject(String(localized: "feedback_subject"))
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}

#Preview {
    SettingsView()
}
