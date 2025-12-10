import SwiftUI
import UserNotifications

@main
struct HolyReminderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState.shared
    @AppStorage("menuBarIcon") private var menuBarIcon = "book.closed.fill"
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
        } label: {
            Image(systemName: menuBarIcon)
                .symbolRenderingMode(.hierarchical)
        }
        .menuBarExtraStyle(.window)
        
        // Settings Window
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
        
        // Mood Selection Window (shown on first launch)
        WindowGroup(id: "mood-selection") {
            MoodSelectionView()
                .environmentObject(appState)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide from dock
        NSApp.setActivationPolicy(.accessory)
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permissions granted")
            }
        }
        
        // Set delegate for handling notifications
        UNUserNotificationCenter.current().delegate = self
        
        // Check if mood was selected today
        checkAndShowMoodSelection()
        
        // Start notification scheduler
        NotificationManager.shared.startScheduler()
        
        // Check for updates if enabled
        if AppState.shared.checkForUpdates {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                UpdateManager.shared.checkForUpdates()
            }
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        NotificationManager.shared.stopScheduler()
    }
    
    private func checkAndShowMoodSelection() {
        // Use AppState to get the date safely (handles String/Date conversion from AppStorage)
        let lastMoodDate = AppState.shared.lastMoodDate
        let calendar = Calendar.current
        
        // If never set or not set today, show window
        if lastMoodDate == nil || !calendar.isDateInToday(lastMoodDate!) {
            print("👋 Mood not set today, showing selection window")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == "mood-selection" }) {
                    window.makeKeyAndOrderFront(nil)
                    NSApp.activate(ignoringOtherApps: true)
                } else {
                    // Open mood selection window
                    NSApp.sendAction(Selector(("showMoodWindow:")), to: nil, from: nil)
                }
            }
        } else {
            print("✅ Mood already set today: \(lastMoodDateString(lastMoodDate))")
        }
    }
    
    private func lastMoodDateString(_ date: Date?) -> String {
        guard let date = date else { return "nil" }
        return ISO8601DateFormatter().string(from: date)
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show banner and sound, list keeps it in notification center longer
        completionHandler([.banner, .sound, .list])
    }
    
    // Handle notification actions (click or Amen button)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let categoryId = response.notification.request.content.categoryIdentifier
        
        DispatchQueue.main.async {
            if categoryId == "BIBLE_VERSE" {
                // Get verse info from notification
                if let reference = userInfo["reference"] as? String,
                   let fullText = userInfo["fullText"] as? String,
                   let category = userInfo["category"] as? String {
                    
                    let verse = BibleVerse(reference: reference, text: fullText, category: category)
                    let mood = AppState.shared.selectedMood
                    
                    // Open verse detail window
                    VerseDetailWindowController.shared.showVerse(verse, mood: mood)
                }
            } else if categoryId == "PRAYER_REMINDER" {
                // Show a generic prayer detail
                let reminder = PrayerReminder.random()
                PrayerDetailWindowController.shared.showPrayer(reminder)
            }
        }
        
        completionHandler()
    }
}
