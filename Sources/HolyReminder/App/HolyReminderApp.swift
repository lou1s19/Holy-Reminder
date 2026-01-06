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
        
        // Tutorial Window (shown on very first launch)
        WindowGroup(id: "tutorial") {
            TutorialView()
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
                log("✅ Notification permissions granted")
            } else {
                log("❌ Notification permissions denied. Error: \(error?.localizedDescription ?? "none")")
            }
            
            // Also check current status
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                log("📋 Notification status: \(settings.authorizationStatus.rawValue) (0=notDetermined, 1=denied, 2=authorized, 3=provisional)")
            }
        }
        
        // Set delegate for handling notifications
        UNUserNotificationCenter.current().delegate = self
        
        // Check if this is first launch - show tutorial
        let tutorialCompleted = UserDefaults.standard.bool(forKey: "tutorialCompleted")
        if !tutorialCompleted {
            showTutorial()
        } else {
            // Always show mood selection on app launch
            showMoodSelection()
        }
        
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
    
    // Prevent app from terminating when last window closes (e.g., after Amen)
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        log("❌ applicationShouldTerminateAfterLastWindowClosed called - returning false")
        return false
    }
    
    private func showTutorial() {
        log("📖 First launch, showing tutorial...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let window = NSApp.windows.first(where: { $0.identifier?.rawValue.contains("tutorial") == true }) {
                window.level = .floating
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    private func showMoodSelection() {
        log("👋 Showing mood selection window...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            // First, try to find existing mood-selection window
            if let window = NSApp.windows.first(where: { $0.identifier?.rawValue.contains("mood-selection") == true }) {
                window.level = .screenSaver  // Highest z-index to appear above everything
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                window.makeKeyAndOrderFront(nil)
                window.orderFrontRegardless()
                NSApp.activate(ignoringOtherApps: true)
                log("✅ Found and activated mood-selection window")
            } else {
                // Window not created yet - create it manually
                log("⚠️ Mood window not found, creating manually...")
                let hostingController = NSHostingController(rootView: 
                    MoodSelectionView()
                        .environmentObject(AppState.shared)
                )
                let window = NSWindow(contentViewController: hostingController)
                window.title = "Stimmung wählen"
                window.styleMask = [.borderless, .fullSizeContentView]
                window.isMovableByWindowBackground = true
                window.backgroundColor = .clear
                window.level = .screenSaver
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                window.center()
                window.makeKeyAndOrderFront(nil)
                window.orderFrontRegardless()
                NSApp.activate(ignoringOtherApps: true)
                log("✅ Created and showed mood-selection window manually")
            }
        }
    }
    
    private func lastMoodDateString(_ date: Date?) -> String {
        guard let date = date else { return "nil" }
        return ISO8601DateFormatter().string(from: date)
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        log("🔔 Notification will present foreground")
        // Show banner and sound, list keeps it in notification center longer
        completionHandler([.banner, .sound, .list])
    }
    
    // Handle notification actions (click or Amen button)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        log("👆 Notification response received: \(response.actionIdentifier)")
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
                    log("Opening Verse Detail Window")
                    VerseDetailWindowController.shared.showVerse(verse, mood: mood)
                }
            } else if categoryId == "PRAYER_REMINDER" {
                let mood = AppState.shared.selectedMood
                
                // Check if it's a spoken prayer with stored info
                if let type = userInfo["type"] as? String, type == "spoken_prayer",
                   let title = userInfo["title"] as? String,
                   let text = userInfo["text"] as? String,
                   let emoji = userInfo["emoji"] as? String,
                   let categoryRaw = userInfo["category"] as? String,
                   let category = SpokenPrayer.PrayerCategory(rawValue: categoryRaw) {
                    
                    log("Opening Spoken Prayer Detail Window")
                    let prayer = SpokenPrayer(title: title, category: category, emoji: emoji, text: text)
                    SpokenPrayerWindowController.shared.showPrayer(prayer, mood: mood)
                } else {
                    // Fallback: Get a mood-based prayer
                    log("Opening Spoken Prayer Detail Window (fallback)")
                    let prayer = SpokenPrayer.forMood(mood)
                    SpokenPrayerWindowController.shared.showPrayer(prayer, mood: mood)
                }
            }
        }
        
        completionHandler()
    }
}

// Simple Logger
func log(_ message: String) {
    print(message)
    let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
    let logFile = desktop.appendingPathComponent("HolyReminder_debug.log")
    let timestamp = ISO8601DateFormatter().string(from: Date())
    let logEntry = "\(timestamp): \(message)\n"
    
    if let data = logEntry.data(using: .utf8) {
        if FileManager.default.fileExists(atPath: logFile.path) {
            if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            try? data.write(to: logFile)
        }
    }
}
