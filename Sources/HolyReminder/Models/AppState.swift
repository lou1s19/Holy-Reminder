import SwiftUI
import Combine

class AppState: ObservableObject {
    static let shared = AppState()
    
    @AppStorage("selectedMood") var selectedMood: Mood = .joyful
    @AppStorage("lastMoodDate") var lastMoodDateString: String = ""
    @AppStorage("reminderFrequency") var reminderFrequency: Double = 0.5 // 0 = selten, 1 = häufig
    @AppStorage("prayerRemindersEnabled") var prayerRemindersEnabled: Bool = true
    @AppStorage("launchAtStartup") var launchAtStartup: Bool = false
    @AppStorage("quietHoursEnabled") var quietHoursEnabled: Bool = false
    @AppStorage("quietHoursStart") var quietHoursStart: Int = 22 // 22:00
    @AppStorage("quietHoursEnd") var quietHoursEnd: Int = 7 // 07:00
    @AppStorage("isPaused") var isPaused: Bool = false
    
    // New settings
    @AppStorage("menuBarIcon") var menuBarIcon: String = "book.closed.fill"
    @AppStorage("notificationSoundEnabled") var notificationSoundEnabled: Bool = true
    @AppStorage("showVersePreview") var showVersePreview: Bool = true
    @AppStorage("askMoodDaily") var askMoodDaily: Bool = true
    @AppStorage("checkForUpdates") var checkForUpdates: Bool = true // New setting
    @AppStorage("playPrayerSound") var playPrayerSound: Bool = true
    @AppStorage("notificationStyle") var notificationStyle: NotificationStyle = .standard
    
    enum NotificationStyle: String, CaseIterable, Identifiable {
        case standard = "Standard"
        case persistent = "Persistent"
        
        var id: String { rawValue }
        
        var label: String {
            switch self {
            case .standard: return "Standard (Benachrichtigung)"
            case .persistent: return "Persistent (Fenster öffnet sofort)"
            }
        }
    }
    
    @Published var currentVerse: BibleVerse?
    @Published var nextReminderTime: Date?
    @Published var showMoodSelection: Bool = false
    @Published var availableUpdate: UpdateInfo? // Holds update info if found
    
    var lastMoodDate: Date? {
        get {
            guard !lastMoodDateString.isEmpty else { return nil }
            return ISO8601DateFormatter().date(from: lastMoodDateString)
        }
        set {
            if let date = newValue {
                lastMoodDateString = ISO8601DateFormatter().string(from: date)
            } else {
                lastMoodDateString = ""
            }
        }
    }
    
    func setMood(_ mood: Mood) {
        selectedMood = mood
        lastMoodDate = Date()
        
        // Reschedule notifications with new mood
        NotificationManager.shared.rescheduleNotifications()
    }
    
    func isInQuietHours() -> Bool {
        guard quietHoursEnabled else { return false }
        
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        
        if quietHoursStart > quietHoursEnd {
            // Crosses midnight (e.g., 22:00 - 07:00)
            return hour >= quietHoursStart || hour < quietHoursEnd
        } else {
            // Same day (e.g., 13:00 - 15:00)
            return hour >= quietHoursStart && hour < quietHoursEnd
        }
    }
    
    // Calculate interval based on frequency setting
    func getRandomInterval() -> TimeInterval {
        // Base intervals in seconds
        let minInterval: TimeInterval = 30 * 60  // 30 minutes
        let maxInterval: TimeInterval = 180 * 60 // 3 hours
        
        // Adjust based on frequency (higher frequency = shorter intervals)
        let adjustedMin = minInterval + (1 - reminderFrequency) * 30 * 60
        let adjustedMax = maxInterval - reminderFrequency * 60 * 60
        
        return TimeInterval.random(in: adjustedMin...adjustedMax)
    }
}
