import Foundation

struct BibleVerse: Codable, Identifiable {
    let id: UUID
    let reference: String
    let text: String
    let category: String
    
    init(id: UUID = UUID(), reference: String, text: String, category: String) {
        self.id = id
        self.reference = reference
        self.text = text
        self.category = category
    }
    
    // Short version for notifications (max 100 chars)
    var shortText: String {
        if text.count <= 100 {
            return text
        }
        let truncated = String(text.prefix(97))
        if let lastSpace = truncated.lastIndex(of: " ") {
            return String(truncated[..<lastSpace]) + "..."
        }
        return truncated + "..."
    }
}

struct PrayerReminder: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let emoji: String
    
    static let reminders: [PrayerReminder] = [
        PrayerReminder(title: "Zeit zum Beten", message: "Nimm dir einen Moment, um mit Gott zu sprechen.", emoji: "🙏"),
        PrayerReminder(title: "Gebet für andere", message: "Bete für jemanden, der dir am Herzen liegt.", emoji: "❤️"),
        PrayerReminder(title: "Dankbarkeit", message: "Wofür bist du heute dankbar?", emoji: "🙌"),
        PrayerReminder(title: "Stille vor Gott", message: "Gönn dir einen Moment der Stille in Gottes Gegenwart.", emoji: "🕊️"),
        PrayerReminder(title: "Fürbitte", message: "Bete für deine Stadt und dein Land.", emoji: "🌍"),
        PrayerReminder(title: "Lobpreis", message: "Vergiss nicht, Gott zu loben für wer er ist.", emoji: "✨"),
        PrayerReminder(title: "Vergebung", message: "Gibt es jemanden, dem du vergeben solltest?", emoji: "💫"),
        PrayerReminder(title: "Gottes Führung", message: "Bitte Gott um Weisheit für heute.", emoji: "🧭")
    ]
    
    static func random() -> PrayerReminder {
        reminders.randomElement()!
    }
}
