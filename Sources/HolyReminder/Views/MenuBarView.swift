import SwiftUI
import UserNotifications

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openWindow) private var openWindow
    @ObservedObject var locManager = LocalizationManager.shared
    @State private var isHoveringVerse = false
    @State private var notificationsEnabled = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with current mood
            HStack {
                Image(systemName: moodIcon(for: appState.selectedMood))
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: appState.selectedMood.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Holy Reminder")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    
                    Text(appState.selectedMood.title)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Status indicator
                Circle()
                    .fill(appState.isPaused ? .orange : (notificationsEnabled ? .green : .red))
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke((appState.isPaused ? Color.orange : (notificationsEnabled ? Color.green : Color.red)).opacity(0.3), lineWidth: 3)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color(nsColor: .windowBackgroundColor))
            
            Divider()
            
            // Notification warning if disabled
            if !notificationsEnabled {
                Button(action: openNotificationSettings) {
                    HStack(spacing: 8) {
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.orange)
                        
                        Text(L10n("menu_activate_notifications"))
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.forward")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.orange.opacity(0.1))
                }
                .buttonStyle(.plain)
                
                Divider()
            }
            
            // Current verse card
            if let verse = appState.currentVerse {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(L10n("menu_verse_title"))
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Button(action: { copyVerse(verse) }) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .help(L10n("menu_copy_help"))
                    }
                    
                    Text(verse.reference)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(appState.selectedMood.accentColor)
                    
                    Text(verse.text)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .scaleEffect(isHoveringVerse ? 1.01 : 1)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHoveringVerse = hovering
                    }
                }
            } else {
                Text(L10n("menu_no_verse"))
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
            }
            
            // Next reminder time
            if !appState.isPaused, let nextTime = appState.nextReminderTime {
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    
                    Text("\(L10n("menu_next_reminder")) \(formatTime(nextTime))")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
            
            // Paused indicator
            if appState.isPaused {
                HStack {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.orange)
                    
                    Text(L10n("menu_paused"))
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(.orange)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
            
            Divider()
            
            // Action buttons
            VStack(spacing: 0) {
                MenuButton(icon: "face.smiling", title: L10n("menu_mood")) {
                    openWindow(id: "mood-selection")
                }
                
                MenuButton(icon: "hands.clap.fill", title: L10n("menu_prayers")) {
                    PrayerWindowController.shared.showPrayers()
                }
                
                MenuButton(icon: "arrow.triangle.2.circlepath", title: L10n("menu_remind_now")) {
                    NotificationManager.shared.sendTestNotification()
                }
                
                Divider()
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                
                // Pause toggle
                MenuButton(
                    icon: appState.isPaused ? "play.fill" : "pause.fill",
                    title: appState.isPaused ? L10n("menu_resume") : L10n("menu_pause_action")
                ) {
                    appState.isPaused.toggle()
                    if appState.isPaused {
                        NotificationManager.shared.stopScheduler()
                    } else {
                        NotificationManager.shared.startScheduler()
                    }
                }
                
                if #available(macOS 14.0, *) {
                    SettingsLink {
                        HStack(spacing: 10) {
                            Image(systemName: "gear")
                                .font(.system(size: 13))
                                .foregroundStyle(.primary)
                                .frame(width: 20)
                            
                            Text(L10n("menu_settings"))
                                .font(.system(size: 13, design: .rounded))
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(TapGesture().onEnded {
                        // Make settings window float above others after it opens
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
                    })
                } else {
                    MenuButton(icon: "gear", title: L10n("menu_settings")) {
                        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                        // Make settings window float above others
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            for window in NSApp.windows {
                                if window.title.contains("Settings") || window.title.contains("Einstellungen") {
                                    window.level = .floating
                                    window.orderFrontRegardless()
                                    NSApp.activate(ignoringOtherApps: true)
                                    break
                                }
                            }
                        }
                    }
                }
                
                Divider()
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                
                // Donate link - same style as MenuButton
                Link(destination: URL(string: "https://www.paypal.com/paypalme/HoffnungaufJesus")!) {
                    HStack(spacing: 10) {
                        Image(systemName: "heart")
                            .font(.system(size: 13))
                            .foregroundStyle(.pink.opacity(0.5))
                            .frame(width: 20)
                        
                        Text(L10n("menu_support"))
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                MenuButton(icon: "power", title: L10n("menu_quit"), isDestructive: true) {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding(.vertical, 8)
        }
        .frame(width: 320)
        .onAppear {
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
        // Open System Settings > Notifications
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func moodIcon(for mood: Mood) -> String {
        switch mood {
        case .joyful: return "sun.max.fill"
        case .sad: return "cloud.rain.fill"
        case .anxious: return "wind"
        case .thoughtful: return "sparkles"
        case .spiritual: return "hands.clap.fill"
        case .hopeful: return "star.fill"
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func copyVerse(_ verse: BibleVerse) {
        let text = "\(verse.reference)\n\(verse.text)"
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

// Simplified MenuButton without State/Animation to avoid crashes
struct MenuButton: View {
    let icon: String
    let title: String
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(isDestructive ? .red : .primary)
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(isDestructive ? .red : .primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            // Static background on hover - system handled or simple color
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
struct MenuBarView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarView()
            .environmentObject(AppState.shared)
    }
}
#endif
