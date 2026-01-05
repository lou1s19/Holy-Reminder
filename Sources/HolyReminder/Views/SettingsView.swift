import SwiftUI
import ServiceManagement
import UserNotifications
import Combine

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var locManager = LocalizationManager.shared
    @State private var selectedTab: SettingsTab = .general
    
    enum SettingsTab: String, CaseIterable {
        case general = "general"
        case appearance = "appearance"
        case notifications = "notifications"
        case about = "about"
        
        var title: String {
            switch self {
            case .general: return L10n("settings_tab_general")
            case .appearance: return L10n("settings_tab_appearance")
            case .notifications: return L10n("settings_tab_notifications")
            case .about: return L10n("settings_tab_about")
            }
        }
        
        var icon: String {
            switch self {
            case .general: return "gear"
            case .appearance: return "paintbrush"
            case .notifications: return "bell"
            case .about: return "info.circle"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView()
                .environmentObject(appState)
                .tabItem {
                    Label(SettingsTab.general.title, systemImage: SettingsTab.general.icon)
                }
                .tag(SettingsTab.general)
            
            AppearanceSettingsView()
                .environmentObject(appState)
                .tabItem {
                    Label(SettingsTab.appearance.title, systemImage: SettingsTab.appearance.icon)
                }
                .tag(SettingsTab.appearance)
            
            NotificationSettingsView()
                .environmentObject(appState)
                .tabItem {
                    Label(SettingsTab.notifications.title, systemImage: SettingsTab.notifications.icon)
                }
                .tag(SettingsTab.notifications)
            
            AboutView()
                .tabItem {
                    Label(SettingsTab.about.title, systemImage: SettingsTab.about.icon)
                }
                .tag(SettingsTab.about)
        }
        .frame(width: 500, height: 550)
        .onAppear {
            // Make settings window float above other windows
            DispatchQueue.main.async {
                for window in NSApp.windows {
                    if window.identifier?.rawValue.contains("Settings") == true ||
                       window.identifier?.rawValue.contains("settings") == true ||
                       window.title.contains("Settings") ||
                       window.title.contains("Einstellungen") {
                        window.level = .floating
                        window.orderFrontRegardless()
                        NSApp.activate(ignoringOtherApps: true)
                        break
                    }
                }
            }
        }
    }
}

// MARK: - General Settings
struct GeneralSettingsView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var locManager = LocalizationManager.shared
    @State private var launchAtLogin = false
    @State private var notificationsEnabled = false
    
    var body: some View {
        Form {
            // Important Notice Section - Notifications
            if !notificationsEnabled {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.orange)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n("warning_notifications_disabled"))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.orange)
                            Text(L10n("warning_notifications_desc"))
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(L10n("button_open")) {
                            openNotificationSettings()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Label(L10n("warning_title"), systemImage: "bell.badge")
                }
            }
            
            // Important Notice Section - Autostart
            if !launchAtLogin {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "power.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n("warning_autostart_title"))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.blue)
                            Text(L10n("warning_autostart_desc"))
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(L10n("button_activate")) {
                            launchAtLogin = true
                            setLaunchAtLogin(true)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Label(L10n("warning_recommendation"), systemImage: "lightbulb")
                }
            }
            
            Section {
                Picker("Sprache", selection: $locManager.language) {
                    ForEach(Language.allCases) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
            } header: {
                Label("Sprache", systemImage: "globe")
            }
            
            Section {
                Toggle(isOn: $launchAtLogin) {
                    HStack {
                        Text(L10n("settings_autostart"))
                        if launchAtLogin {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.system(size: 14))
                        }
                    }
                }
                .onChange(of: launchAtLogin) { newValue in
                    setLaunchAtLogin(newValue)
                }
            } header: {
                Label(L10n("settings_autostart_header"), systemImage: "power")
            } footer: {
                Text("Die App startet automatisch beim Einschalten deines Macs.")
            }
            
            Section {
                Toggle("Täglich nach Stimmung fragen", isOn: $appState.askMoodDaily)
                
                HStack {
                    Text("Aktuelle Stimmung")
                    Spacer()
                    Text("\(appState.selectedMood.emoji) \(appState.selectedMood.title)")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Label("Stimmung", systemImage: "face.smiling")
            }
            
            Section {
                Toggle("Vers-Vorschau im Menu anzeigen", isOn: $appState.showVersePreview)
            } header: {
                Label("Anzeige", systemImage: "text.quote")
            }
        }
        .formStyle(.grouped)
        .onAppear {
            launchAtLogin = appState.launchAtStartup
            checkNotificationStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            checkNotificationStatus()
        }
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func openNotificationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            appState.launchAtStartup = enabled
        } catch {
            print("❌ Failed to set launch at login: \(error)")
        }
    }
}


// MARK: - Appearance Settings (NEW)
struct AppearanceSettingsView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var locManager = LocalizationManager.shared
    
    // Available menu bar icons
    let menuBarIcons = [
        ("book.closed.fill", "Buch"),
        ("book.fill", "Offenes Buch"),
        ("text.book.closed.fill", "Bibel"),
        ("hands.clap.fill", "Betende Hände"),
        ("cross.fill", "Kreuz"),
        ("star.fill", "Stern"),
        ("heart.fill", "Herz"),
        ("leaf.fill", "Blatt"),
        ("sparkles", "Sterne"),
        ("sun.max.fill", "Sonne")
    ]
    
    var body: some View {
        Form {
            Section {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(menuBarIcons, id: \.0) { icon, name in
                        IconButton(
                            icon: icon,
                            name: name,
                            isSelected: appState.menuBarIcon == icon,
                            action: {
                                withAnimation(.spring(response: 0.3)) {
                                    appState.menuBarIcon = icon
                                }
                            }
                        )
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Label(L10n("settings_icon"), systemImage: "menubar.rectangle")
            } footer: {
                Text(L10n("settings_icon_desc"))
            }
        }
        .formStyle(.grouped)
    }
}

struct IconButton: View {
    let icon: String
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? .white : .primary)
                
                Text(name)
                    .font(.system(size: 10))
                    .foregroundStyle(isSelected ? .white : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 80, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.accentColor : (isHovered ? Color.gray.opacity(0.15) : Color.gray.opacity(0.08)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Notification Settings
struct NotificationSettingsView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var locManager = LocalizationManager.shared
    
    var body: some View {
        Form {
            Section {
                Picker(L10n("settings_interval"), selection: $appState.reminderInterval) {
                    ForEach(AppState.ReminderInterval.allCases) { interval in
                        Text(interval.label).tag(interval)
                    }
                }
                .onChange(of: appState.reminderInterval) { _ in
                    NotificationManager.shared.rescheduleNotifications()
                }
            } header: {
                Label(L10n("settings_frequency_header"), systemImage: "clock")
            } footer: {
                Text(L10n("settings_frequency_footer"))
            }
            
            Section {
                Toggle(L10n("settings_sound_notification"), isOn: $appState.notificationSoundEnabled)
                Toggle(L10n("settings_sound_prayer"), isOn: $appState.playPrayerSound)
            } header: {
                Label(L10n("settings_sounds_header"), systemImage: "speaker.wave.2")
            }
            
            Section {
                Toggle(L10n("settings_prayers_enable"), isOn: $appState.prayerRemindersEnabled)
                    .onChange(of: appState.prayerRemindersEnabled) { newValue in
                        // Reset to default if disabled? Or just keep value.
                        // For now we assume if enabled, we use the probability
                    }
                
                if appState.prayerRemindersEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(L10n("settings_ratio_verse"))
                            Spacer()
                            Text("\(Int((1.0 - appState.prayerProbability) * 100))% / \(Int(appState.prayerProbability * 100))%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(L10n("settings_ratio_prayer"))
                        }
                        
                        Slider(value: $appState.prayerProbability, in: 0...1) {
                            Text(L10n("settings_ratio_label"))
                        }
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Label(L10n("settings_prayers_header"), systemImage: "hands.clap")
            }
            
            Section {
                Toggle(L10n("settings_quiet_hours_enable"), isOn: $appState.quietHoursEnabled)
                
                if appState.quietHoursEnabled {
                    HStack {
                        Text(L10n("quiet_from"))
                        Picker("", selection: $appState.quietHoursStart) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text("\(hour):00").tag(hour)
                            }
                        }
                        .frame(width: 80)
                        
                        Text(L10n("quiet_to"))
                        
                        Picker("", selection: $appState.quietHoursEnd) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text("\(hour):00").tag(hour)
                            }
                        }
                        .frame(width: 80)
                    }
                }
            } header: {
                Label(L10n("settings_quiet_hours_header"), systemImage: "moon")
            } footer: {
                Text(L10n("settings_quiet_hours_desc"))
            }
        }
        .formStyle(.grouped)
    }
}


// MARK: - About View
struct AboutView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var locManager = LocalizationManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "book.closed.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "a855f7"), Color(hex: "6366f1")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Holy Reminder")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            Text("\(L10n("about_version")) 1.1.0")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            
            Text(L10n("about_desc"))
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Divider()
                .frame(width: 200)
            
            VStack(spacing: 12) {
                // Update Checker Section
                if let update = UpdateManager.shared.availableUpdate {
                    VStack(spacing: 8) {
                        Text("🚀 Neues Update verfügbar: \(update.version)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.green)
                        
                        Link("Jetzt herunterladen", destination: update.url)
                            .font(.system(size: 12))
                            .buttonStyle(.borderedProminent)
                        
                        Text(update.changelog)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                } else {
                    Button(action: {
                        UpdateManager.shared.checkForUpdates(manual: true)
                    }) {
                        if UpdateManager.shared.isChecking {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Text(L10n("button_check_update"))
                        }
                    }
                    .disabled(UpdateManager.shared.isChecking)
                    
                    if let error = UpdateManager.shared.lastError {
                        Text(error)
                            .font(.system(size: 10))
                            .foregroundStyle(.red)
                    }
                }
                
                Divider()
                    .frame(width: 200)
                
                Toggle(L10n("settings_auto_update"), isOn: $appState.checkForUpdates)
                    .font(.system(size: 11))
                    .controlSize(.small)
                
                Spacer().frame(height: 10)
                
                Text("Mit ❤️ erstellt")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                
                // Subtle donation links
                HStack(spacing: 16) {
                    Link(destination: URL(string: "https://www.paypal.com/paypalme/HoffnungaufJesus")!) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 10))
                            Text("PayPal")
                                .font(.system(size: 11))
                        }
                        .foregroundStyle(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://gofund.me/0f408ddc")!) {
                        HStack(spacing: 4) {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 10))
                            Text("GoFundMe")
                                .font(.system(size: 11))
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .opacity(0.7)
            }
            
            Spacer()
                .frame(height: 20)
            
            Button(L10n("button_reset")) {
                resetAllSettings()
            }
            .font(.system(size: 11))
            .foregroundStyle(.red.opacity(0.7))
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(UpdateManager.shared.$availableUpdate) { update in
            if update != nil {
                appState.availableUpdate = update
            }
        }
    }
    
    private func resetAllSettings() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppState.shared)
    }
}
#endif
