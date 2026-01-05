import SwiftUI

enum Mood: String, CaseIterable, Codable {
    case joyful = "joyful"
    case sad = "sad"
    case anxious = "anxious"
    case thoughtful = "thoughtful"
    case spiritual = "spiritual"
    case hopeful = "hopeful"
    
    var emoji: String {
        switch self {
        case .joyful: return "😊"
        case .sad: return "😔"
        case .anxious: return "😰"
        case .thoughtful: return "🤔"
        case .spiritual: return "🙏"
        case .hopeful: return "🌟"
        }
    }
    
    var title: String {
        return L10n("mood_\(self.rawValue)")
    }
    
    var description: String {
        return L10n("mood_desc_\(self.rawValue)")
    }
    
    var verseCategory: String {
        switch self {
        case .joyful: return "praise"
        case .sad: return "comfort"
        case .anxious: return "peace"
        case .thoughtful: return "wisdom"
        case .spiritual: return "spiritual"
        case .hopeful: return "praise"  // Uses praise category for hopeful verses
        }
    }
    
    var gradient: [Color] {
        switch self {
        case .joyful:
            return [Color(hex: "FFD93D"), Color(hex: "FF6B6B")]
        case .sad:
            return [Color(hex: "74b9ff"), Color(hex: "a29bfe")]
        case .anxious:
            return [Color(hex: "81ecec"), Color(hex: "74b9ff")]
        case .thoughtful:
            return [Color(hex: "a29bfe"), Color(hex: "fd79a8")]
        case .spiritual:
            return [Color(hex: "fdcb6e"), Color(hex: "e17055")]
        case .hopeful:
            return [Color(hex: "00b894"), Color(hex: "55efc4")]
        }
    }
    
    var accentColor: Color {
        switch self {
        case .joyful: return Color(hex: "FF6B6B")
        case .sad: return Color(hex: "74b9ff")
        case .anxious: return Color(hex: "00cec9")
        case .thoughtful: return Color(hex: "a29bfe")
        case .spiritual: return Color(hex: "e17055")
        case .hopeful: return Color(hex: "00b894")
        }
    }
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
