import Foundation
import UserNotifications
import AppKit // For NSWorkspace

class NotificationManager {
    static let shared = NotificationManager()
    
    private var timer: Timer?
    private var isRunning = false
    
    private init() {
        setupNotificationCategories()
        setupWakeObserver()
    }
    
    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    private func setupWakeObserver() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }
    
    @objc private func handleWake() {
        print("☀️ System woke up, checking notifications...")
        
        guard isRunning else { return }
        
        // Invalidate current timer as it might be unreliable after sleep
        timer?.invalidate()
        
        if let targetDate = AppState.shared.nextReminderTime {
            let now = Date()
            let remaining = targetDate.timeIntervalSince(now)
            
            if remaining <= 0 {
                // Time passed while sleeping
                print("⏰ Time passed during sleep. Sending notification now.")
                // Add a small delay to ensure system is fully awake and ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.sendNotificationIfAppropriate()
                }
            } else {
                // Still time remaining
                print("⏰ Rescheduling for remaining time: \(Int(remaining))s")
                timer = Timer.scheduledTimer(withTimeInterval: remaining, repeats: false) { [weak self] _ in
                    self?.sendNotificationIfAppropriate()
                }
            }
        } else {
            // Fallback if no time set
            rescheduleNotifications()
        }
    }
    
    private func setupNotificationCategories() {
        // Amen action for Bible verses
        let amenAction = UNNotificationAction(
            identifier: "AMEN_ACTION",
            title: "🙏 Amen",
            options: []
        )
        
        // Bible verse category with Amen button
        let verseCategory = UNNotificationCategory(
            identifier: "BIBLE_VERSE",
            actions: [amenAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        // Prayer category
        let prayerCategory = UNNotificationCategory(
            identifier: "PRAYER_REMINDER",
            actions: [amenAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([verseCategory, prayerCategory])
    }
    
    func startScheduler() {
        guard !isRunning else { return }
        isRunning = true
        scheduleNextNotification()
        print("✅ Notification scheduler started")
    }
    
    func stopScheduler() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        print("⏹️ Notification scheduler stopped")
    }
    
    func rescheduleNotifications() {
        stopScheduler()
        startScheduler()
    }
    
    private func scheduleNextNotification() {
        let appState = AppState.shared
        
        // Calculate next interval
        let interval = appState.getRandomInterval()
        let nextTime = Date().addingTimeInterval(interval)
        
        // Update UI
        DispatchQueue.main.async {
            appState.nextReminderTime = nextTime
        }
        
        print("⏰ Next notification scheduled in \(Int(interval / 60)) minutes")
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.sendNotificationIfAppropriate()
        }
    }
    
    private func sendNotificationIfAppropriate() {
        let appState = AppState.shared
        
        // Check quiet hours
        if appState.isInQuietHours() {
            print("🌙 In quiet hours, skipping notification")
            scheduleNextNotification()
            return
        }
        
        // Decide between Bible verse or prayer reminder
        let shouldSendPrayerReminder = appState.prayerRemindersEnabled && Double.random(in: 0...1) < appState.prayerProbability
        
        if shouldSendPrayerReminder {
            sendPrayerReminder()
        } else {
            sendBibleVerseNotification()
        }
        
        // Schedule next notification
        scheduleNextNotification()
    }
    
    private func sendBibleVerseNotification() {
        print("🔍 sendBibleVerseNotification called")
        
        let mood = AppState.shared.selectedMood
        print("🔍 Mood: \(mood)")
        
        guard let verse = VerseManager.shared.getRandomVerse(for: mood) else {
            print("❌ No verse found for mood: \(mood)")
            return
        }
        
        print("🔍 Verse: \(verse.reference)")
        
        // Update current verse in app state
        DispatchQueue.main.async {
            AppState.shared.currentVerse = verse
        }
        
        // CHECK STYLE
        if AppState.shared.notificationStyle == .persistent {
            print("🪟 Persistent mode: Opening window directly")
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
                VerseDetailWindowController.shared.showVerse(verse, mood: mood)
            }
            return
        }
        
        // STANDARD NOTIFICATION
        let content = UNMutableNotificationContent()
        content.title = "📖 \(verse.reference)"
        content.body = verse.shortText
        content.sound = AppState.shared.notificationSoundEnabled ? .default : nil
        content.categoryIdentifier = "BIBLE_VERSE"
        
        // Add full verse to userInfo
        let userInfo: [String: Any] = [
            "reference": verse.reference,
            "fullText": verse.text,
            "category": verse.category
        ]
        content.userInfo = userInfo
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Deliver immediately
        )
        
        print("🔍 Adding notification request...")
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Notification error: \(error)")
            } else {
                print("📖 Bible verse notification sent: \(verse.reference)")
            }
        }
    }
    
    private func sendPrayerReminder() {
        let mood = AppState.shared.selectedMood
        let prayer = SpokenPrayer.forMood(mood)
        
        // CHECK STYLE
        if AppState.shared.notificationStyle == .persistent {
            print("🪟 Persistent mode: Opening spoken prayer window directly")
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
                SpokenPrayerWindowController.shared.showPrayer(prayer, mood: mood)
            }
            return
        }
        
        // STANDARD NOTIFICATION
        let content = UNMutableNotificationContent()
        content.title = "\(prayer.emoji) Zeit zum Beten"
        content.body = "\(prayer.title) - Tippe zum Mitsprechen"
        content.sound = AppState.shared.notificationSoundEnabled ? .default : nil
        content.categoryIdentifier = "PRAYER_REMINDER"
        
        // Store prayer info for when user taps
        content.userInfo = [
            "type": "spoken_prayer",
            "title": prayer.title,
            "text": prayer.text,
            "emoji": prayer.emoji,
            "category": prayer.category.rawValue
        ]
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Notification error: \(error)")
            } else {
                print("🙏 Prayer reminder sent: \(prayer.title)")
            }
        }
    }
    
    // For testing - send a notification immediately
    func sendTestNotification() {
        sendBibleVerseNotification()
    }
}
