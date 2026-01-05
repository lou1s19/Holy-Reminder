import SwiftUI
import Combine

class AppState: ObservableObject {
    static let shared = AppState()
    
    @AppStorage("selectedMood") var selectedMood: Mood = .joyful
    @AppStorage("lastMoodDate") var lastMoodDateString: String = ""
    @AppStorage("reminderInterval") var reminderInterval: ReminderInterval = .twoHours
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
    @AppStorage("prayerProbability") var prayerProbability: Double = 0.3 // 30% probability for prayer vs verse
    
    // Reminder Interval options
    enum ReminderInterval: String, CaseIterable, Identifiable {
        case tenMinutes = "10min"
        case thirtyMinutes = "30min"
        case oneHour = "1h"
        case twoHours = "2h"
        case threeHours = "3h"
        case fourHours = "4h"
        
        var id: String { rawValue }
        
        var label: String {
            switch self {
            case .tenMinutes: return "10 Minuten"
            case .thirtyMinutes: return "30 Minuten"
            case .oneHour: return "1 Stunde"
            case .twoHours: return "2 Stunden"
            case .threeHours: return "3 Stunden"
            case .fourHours: return "4 Stunden"
            }
        }
        
        var seconds: TimeInterval {
            switch self {
            case .tenMinutes: return 10 * 60
            case .thirtyMinutes: return 30 * 60
            case .oneHour: return 60 * 60
            case .twoHours: return 2 * 60 * 60
            case .threeHours: return 3 * 60 * 60
            case .fourHours: return 4 * 60 * 60
            }
        }
    }
    
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
    
    // Get the interval based on the selected option
    func getInterval() -> TimeInterval {
        return reminderInterval.seconds
    }
    
    // For backwards compatibility - now just returns the fixed interval
    func getRandomInterval() -> TimeInterval {
        return reminderInterval.seconds
    }
}
