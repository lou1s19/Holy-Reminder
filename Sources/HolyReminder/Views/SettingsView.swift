import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: SettingsTab = .general
    
    enum SettingsTab: String, CaseIterable {
        case general = "Allgemein"
        case appearance = "Aussehen"
        case notifications = "Erinnerungen"
        case about = "Über"
        
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
                    Label(SettingsTab.general.rawValue, systemImage: SettingsTab.general.icon)
                }
                .tag(SettingsTab.general)
            
            AppearanceSettingsView()
                .environmentObject(appState)
                .tabItem {
                    Label(SettingsTab.appearance.rawValue, systemImage: SettingsTab.appearance.icon)
                }
                .tag(SettingsTab.appearance)
            
            NotificationSettingsView()
                .environmentObject(appState)
                .tabItem {
                    Label(SettingsTab.notifications.rawValue, systemImage: SettingsTab.notifications.icon)
                }
                .tag(SettingsTab.notifications)
            
            AboutView()
                .tabItem {
                    Label(SettingsTab.about.rawValue, systemImage: SettingsTab.about.icon)
                }
                .tag(SettingsTab.about)
        }
        .frame(width: 500, height: 420)
    }
}

// MARK: - General Settings
struct GeneralSettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var launchAtLogin = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Bei Anmeldung starten", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        setLaunchAtLogin(newValue)
                    }
            } header: {
                Label("Systemstart", systemImage: "power")
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
                Label("Menüleisten-Icon", systemImage: "menubar.rectangle")
            } footer: {
                Text("Wähle ein Icon für die Menüleiste. Änderung erfordert Neustart.")
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
                    .font(.system(size: 9))
                    .foregroundStyle(isSelected ? .white : .secondary)
                    .lineLimit(1)
            }
            .frame(width: 70, height: 60)
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
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Häufigkeit")
                        Spacer()
                        Text(frequencyLabel)
                            .foregroundStyle(.secondary)
                            .font(.system(size: 12))
                    }
                    
                    Slider(value: $appState.reminderFrequency, in: 0...1) {
                        EmptyView()
                    } minimumValueLabel: {
                        Text("Selten")
                            .font(.system(size: 10))
                    } maximumValueLabel: {
                        Text("Häufig")
                            .font(.system(size: 10))
                    }
                    .onChange(of: appState.reminderFrequency) { _ in
                        NotificationManager.shared.rescheduleNotifications()
                    }
                    
                    Text("Intervall: ca. \(intervalDescription)")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
            } header: {
                Label("Erinnerungs-Frequenz", systemImage: "clock")
            }
            
            Section {
                Toggle("Benachrichtigungston aktivieren", isOn: $appState.notificationSoundEnabled)
                Toggle("Gebetssound abspielen", isOn: $appState.playPrayerSound)
            } header: {
                Label("Töne", systemImage: "speaker.wave.2")
            }
            
            Section {
                Toggle("Gebetserinnerungen aktivieren", isOn: $appState.prayerRemindersEnabled)
            } header: {
                Label("Gebetserinnerungen", systemImage: "hands.clap")
            }
            
            Section {
                Toggle("Stille Zeiten aktivieren", isOn: $appState.quietHoursEnabled)
                
                if appState.quietHoursEnabled {
                    HStack {
                        Text("Von")
                        Picker("", selection: $appState.quietHoursStart) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text("\(hour):00").tag(hour)
                            }
                        }
                        .frame(width: 80)
                        
                        Text("bis")
                        
                        Picker("", selection: $appState.quietHoursEnd) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text("\(hour):00").tag(hour)
                            }
                        }
                        .frame(width: 80)
                    }
                }
            } header: {
                Label("Stille Zeiten", systemImage: "moon")
            } footer: {
                Text("Während der stillen Zeit werden keine Benachrichtigungen gesendet.")
            }
        }
        .formStyle(.grouped)
    }
    
    private var frequencyLabel: String {
        switch appState.reminderFrequency {
        case 0..<0.25: return "Sehr selten"
        case 0.25..<0.5: return "Selten"
        case 0.5..<0.75: return "Normal"
        case 0.75...1: return "Häufig"
        default: return "Normal"
        }
    }
    
    private var intervalDescription: String {
        let interval = appState.getRandomInterval()
        let minutes = Int(interval / 60)
        if minutes < 60 {
            return "\(minutes) Minuten"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours) Stunde\(hours > 1 ? "n" : "")"
            }
            return "\(hours) Std. \(remainingMinutes) Min."
        }
    }
}

// MARK: - About View
struct AboutView: View {
    @EnvironmentObject var appState: AppState
    
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
            
            Text("Version 1.0.0")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            
            Text("Tägliche Bibelerinnerungen für deinen Mac")
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
                            Text("Nach Updates suchen")
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
                
                Toggle("Automatisch nach Updates suchen", isOn: $appState.checkForUpdates)
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
            
            Button("Daten zurücksetzen") {
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

#Preview {
    SettingsView()
        .environmentObject(AppState.shared)
}
