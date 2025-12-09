import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private var timer: Timer?
    private var isRunning = false
    
    private init() {
        setupNotificationCategories()
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
        let shouldSendPrayerReminder = appState.prayerRemindersEnabled && Bool.random()
        
        if shouldSendPrayerReminder {
            sendPrayerReminder()
        } else {
            sendBibleVerseNotification()
        }
        
        // Schedule next notification
        scheduleNextNotification()
    }
    
    private func sendBibleVerseNotification() {
        let mood = AppState.shared.selectedMood
        
        guard let verse = VerseManager.shared.getRandomVerse(for: mood) else {
            print("❌ No verse found for mood: \(mood)")
            return
        }
        
        // Update current verse in app state
        DispatchQueue.main.async {
            AppState.shared.currentVerse = verse
        }
        
        let content = UNMutableNotificationContent()
        content.title = "📖 \(verse.reference)"
        content.body = verse.shortText
        content.sound = .default
        content.categoryIdentifier = "BIBLE_VERSE"
        
        // Add full verse to userInfo for potential "Read More" action
        content.userInfo = [
            "reference": verse.reference,
            "fullText": verse.text,
            "category": verse.category
        ]
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Deliver immediately
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Notification error: \(error)")
            } else {
                print("📖 Bible verse notification sent: \(verse.reference)")
            }
        }
    }
    
    private func sendPrayerReminder() {
        let reminder = PrayerReminder.random()
        
        let content = UNMutableNotificationContent()
        content.title = "\(reminder.emoji) \(reminder.title)"
        content.body = reminder.message
        content.sound = .default
        content.categoryIdentifier = "PRAYER_REMINDER"
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Notification error: \(error)")
            } else {
                print("🙏 Prayer reminder sent: \(reminder.title)")
            }
        }
    }
    
    // For testing - send a notification immediately
    func sendTestNotification() {
        sendBibleVerseNotification()
    }
}
