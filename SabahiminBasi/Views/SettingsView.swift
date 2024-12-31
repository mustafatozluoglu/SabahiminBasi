import SwiftUI
import MessageUI
import UserNotifications

struct SettingsView: View {
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("timerEnabled") private var timerEnabled = false
    @AppStorage("timerInterval") private var timerInterval = 1.0
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var showingMailCompose = false
    @State private var showingSuccessAlert = false
    @State private var showingLanguageAlert = false
    @Environment(\.colorScheme) var colorScheme
    
    private let languages = [
        "en": "English",
        "tr": "Türkçe"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    settingsSection(header: LocalizedStringKey("general")) {
                        Toggle(LocalizedStringKey("dark_mode"), isOn: $darkModeEnabled)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .onChange(of: darkModeEnabled) { newValue in
                                setAppearance(newValue)
                            }
                        
                        Divider()
                        
                        HStack {
                            Text(LocalizedStringKey("language"))
                            Spacer()
                            Menu {
                                Button("English") {
                                    languageManager.setLanguage("en")
                                    showingLanguageAlert = true
                                }
                                Button("Türkçe") {
                                    languageManager.setLanguage("tr")
                                    showingLanguageAlert = true
                                }
                            } label: {
                                HStack {
                                    Text(languages[languageManager.currentLanguage] ?? "")
                                        .foregroundColor(.secondary)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .foregroundColor(.secondary)
                                        .imageScale(.small)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        
                        Divider()
                        
                        Toggle(LocalizedStringKey("haptic_feedback"), isOn: $hapticFeedbackEnabled)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                    }
                    
                    settingsSection(header: LocalizedStringKey("timer")) {
                        Toggle(LocalizedStringKey("timer_enabled"), isOn: $timerEnabled)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        
                        if timerEnabled {
                            Divider()
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text(LocalizedStringKey("interval"))
                                    Spacer()
                                    Text(String(format: "%.1f", timerInterval))
                                }
                                
                                Slider(value: $timerInterval, in: 0.1...30.0, step: 0.1)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                    }
                    
                    settingsSection(header: LocalizedStringKey("notifications")) {
                        Toggle(LocalizedStringKey("notifications_enabled"), isOn: $notificationsEnabled)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .onChange(of: notificationsEnabled) { newValue in
                                if newValue {
                                    requestNotificationPermission()
                                }
                            }
                    }
                    
                    settingsSection(header: LocalizedStringKey("about")) {
                        Button(action: {
                            showingMailCompose = true
                        }) {
                            HStack {
                                Text(LocalizedStringKey("send_feedback"))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        
                        Divider()
                        
                        HStack {
                            Text(LocalizedStringKey("version"))
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(LocalizedStringKey("settings"))
            .background(Color(.systemGroupedBackground))
            .alert(LocalizedStringKey("language_changed"), isPresented: $showingLanguageAlert) {
                Button(LocalizedStringKey("ok")) {}
            } message: {
                Text(LocalizedStringKey("restart_required"))
            }
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
            setAppearance(darkModeEnabled)
        }
    }
    
    private func settingsSection<Content: View>(header: LocalizedStringKey, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(header)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal)
                .padding(.vertical, 8)
            
            VStack(spacing: 0) {
                content()
            }
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(10)
            .padding(.horizontal)
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
