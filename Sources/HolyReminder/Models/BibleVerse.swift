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

// MARK: - Spoken Prayers (Gebete zum Mitsprechen)
struct SpokenPrayer: Identifiable {
    let id: UUID
    let title: String
    let category: PrayerCategory
    let emoji: String
    let text: String
    
    init(id: UUID = UUID(), title: String, category: PrayerCategory, emoji: String, text: String) {
        self.id = id
        self.title = title
        self.category = category
        self.emoji = emoji
        self.text = text
    }
    
    enum PrayerCategory: String, CaseIterable, Identifiable {
        case morning = "morning"
        case evening = "evening"
        case thanksgiving = "thanksgiving"
        case protection = "protection"
        case guidance = "guidance"
        case peace = "peace"
        case strength = "strength"
        case forgiveness = "forgiveness"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .morning: return "sunrise.fill"
            case .evening: return "moon.stars.fill"
            case .thanksgiving: return "heart.fill"
            case .protection: return "shield.fill"
            case .guidance: return "compass.drawing"
            case .peace: return "leaf.fill"
            case .strength: return "bolt.fill"
            case .forgiveness: return "hands.clap.fill"
            }
        }
        
        var localizedName: String {
            let lang = LocalizationManager.shared.language
            switch self {
            case .morning:
                switch lang {
                case .german: return "Morgengebete"
                case .english: return "Morning Prayers"
                case .russian: return "Утренние молитвы"
                case .spanish: return "Oraciones matutinas"
                case .french: return "Prières du matin"
                }
            case .evening:
                switch lang {
                case .german: return "Abendgebete"
                case .english: return "Evening Prayers"
                case .russian: return "Вечерние молитвы"
                case .spanish: return "Oraciones vespertinas"
                case .french: return "Prières du soir"
                }
            case .thanksgiving:
                switch lang {
                case .german: return "Dankgebete"
                case .english: return "Thanksgiving"
                case .russian: return "Благодарность"
                case .spanish: return "Acción de gracias"
                case .french: return "Action de grâce"
                }
            case .protection:
                switch lang {
                case .german: return "Schutzgebete"
                case .english: return "Protection"
                case .russian: return "Защита"
                case .spanish: return "Protección"
                case .french: return "Protection"
                }
            case .guidance:
                switch lang {
                case .german: return "Führung"
                case .english: return "Guidance"
                case .russian: return "Руководство"
                case .spanish: return "Guía"
                case .french: return "Guidance"
                }
            case .peace:
                switch lang {
                case .german: return "Frieden"
                case .english: return "Peace"
                case .russian: return "Мир"
                case .spanish: return "Paz"
                case .french: return "Paix"
                }
            case .strength:
                switch lang {
                case .german: return "Kraft & Mut"
                case .english: return "Strength"
                case .russian: return "Сила"
                case .spanish: return "Fuerza"
                case .french: return "Force"
                }
            case .forgiveness:
                switch lang {
                case .german: return "Vergebung"
                case .english: return "Forgiveness"
                case .russian: return "Прощение"
                case .spanish: return "Perdón"
                case .french: return "Pardon"
                }
            }
        }
    }
    
    static let germanPrayers: [SpokenPrayer] = [
        // Morgengebete
        SpokenPrayer(
            title: "Morgengebet",
            category: .morning,
            emoji: "🌅",
            text: """
            Herr, ich danke dir für diesen neuen Tag.
            Ich lege ihn in deine Hände.
            Führe mich heute auf deinen Wegen.
            Gib mir Weisheit für jede Entscheidung
            und Liebe für jeden Menschen, dem ich begegne.
            Lass mich heute ein Segen sein.
            Amen.
            """
        ),
        SpokenPrayer(
            title: "Tagesanfang",
            category: .morning,
            emoji: "☀️",
            text: """
            Guter Gott,
            mit dir beginne ich diesen Tag.
            Du bist mein Licht und meine Hoffnung.
            Begleite mich durch alle Stunden,
            stärke mich in Schwierigkeiten,
            und erfülle mich mit deiner Freude.
            In Jesu Namen, Amen.
            """
        ),
        
        // Abendgebete
        SpokenPrayer(
            title: "Abendgebet",
            category: .evening,
            emoji: "🌙",
            text: """
            Herr, der Tag geht zu Ende.
            Ich danke dir für alles Gute,
            das ich heute erleben durfte.
            Vergib mir, wo ich gefehlt habe.
            Schenke mir erholsamen Schlaf
            und lass mich morgen neu beginnen.
            In deine Hände lege ich mich.
            Amen.
            """
        ),
        SpokenPrayer(
            title: "Nachtruhe",
            category: .evening,
            emoji: "✨",
            text: """
            Vater im Himmel,
            bewahre mich in dieser Nacht.
            Lass mich in deinem Frieden ruhen.
            Schütze meine Familie und alle, die ich liebe.
            Wenn der Morgen kommt,
            lass mich mit neuer Kraft erwachen.
            Amen.
            """
        ),
        
        // Dankgebete
        SpokenPrayer(
            title: "Dankgebet",
            category: .thanksgiving,
            emoji: "🙏",
            text: """
            Herr, ich danke dir von ganzem Herzen.
            Für das Leben, das du mir schenkst,
            für die Menschen, die mich lieben,
            für jede Gnade, die ich empfange.
            Du bist gut, und deine Güte währt ewiglich.
            Lob und Dank sei dir!
            Amen.
            """
        ),
        SpokenPrayer(
            title: "Für Segnungen",
            category: .thanksgiving,
            emoji: "🎁",
            text: """
            Gütiger Gott,
            ich erkenne deine Segnungen in meinem Leben.
            Danke für Gesundheit, Nahrung und ein Dach über dem Kopf.
            Danke für Freunde und Familie.
            Hilf mir, niemals selbstverständlich zu nehmen,
            was du mir schenkst.
            Amen.
            """
        ),
        
        // Schutzgebete
        SpokenPrayer(
            title: "Schutzgebet",
            category: .protection,
            emoji: "🛡️",
            text: """
            Herr, du bist meine Zuflucht und meine Burg.
            Ich vertraue auf dich.
            Beschütze mich vor allem Bösen.
            Stelle deine Engel um mich her.
            In deiner Hand bin ich geborgen.
            Nichts kann mich von deiner Liebe trennen.
            Amen.
            """
        ),
        
        // Führung
        SpokenPrayer(
            title: "Um Führung",
            category: .guidance,
            emoji: "🧭",
            text: """
            Herr, zeige mir deinen Weg.
            Ich stehe vor Entscheidungen
            und weiß nicht, wohin ich gehen soll.
            Leite mich durch deinen Heiligen Geist.
            Öffne Türen, die du öffnen willst,
            und schließe, was nicht von dir ist.
            Ich vertraue dir.
            Amen.
            """
        ),
        SpokenPrayer(
            title: "Weisheit",
            category: .guidance,
            emoji: "💡",
            text: """
            Gott der Weisheit,
            schenke mir Erkenntnis von oben.
            Lass mich unterscheiden können,
            was richtig und was falsch ist.
            Gib mir ein hörendes Herz
            für deine Stimme.
            In Jesu Namen, Amen.
            """
        ),
        
        // Frieden
        SpokenPrayer(
            title: "Friedensgebet",
            category: .peace,
            emoji: "🕊️",
            text: """
            Herr, mach mich zu einem Werkzeug deines Friedens.
            Wo Hass ist, lass mich Liebe säen.
            Wo Zwietracht ist, Einheit.
            Wo Irrtum ist, Wahrheit.
            Wo Verzweiflung ist, Hoffnung.
            Wo Dunkelheit ist, Licht.
            Amen.
            """
        ),
        SpokenPrayer(
            title: "Innerer Frieden",
            category: .peace,
            emoji: "☮️",
            text: """
            Jesus, du hast gesagt: Meinen Frieden gebe ich euch.
            Ich öffne mein Herz für deinen Frieden.
            Nimm alle Unruhe von mir.
            Stille die Stürme in meiner Seele.
            Lass mich ruhen in dir.
            Amen.
            """
        ),
        
        // Kraft & Mut
        SpokenPrayer(
            title: "Stärke",
            category: .strength,
            emoji: "💪",
            text: """
            Herr, ich bin schwach, aber du bist stark.
            Gib mir Kraft für diesen Tag.
            Wenn ich müde bin, erneuere mich.
            Wenn ich verzagt bin, ermutige mich.
            Deine Kraft ist in den Schwachen mächtig.
            Ich vertraue auf dich allein.
            Amen.
            """
        ),
        SpokenPrayer(
            title: "Mut",
            category: .strength,
            emoji: "🦁",
            text: """
            Gott, nimm alle Furcht von mir.
            Du hast mir nicht einen Geist der Angst gegeben,
            sondern der Kraft, der Liebe und der Besonnenheit.
            Hilf mir, mutig zu sein.
            Mit dir an meiner Seite
            kann ich alles überwinden.
            Amen.
            """
        ),
        
        // Vergebung
        SpokenPrayer(
            title: "Vergebung bitten",
            category: .forgiveness,
            emoji: "💔",
            text: """
            Barmherziger Vater,
            ich habe gesündigt gegen dich und andere.
            Vergib mir meine Schuld.
            Reinige mein Herz.
            Hilf mir, anders zu leben.
            Danke, dass du mich nicht verwirfst,
            sondern mit offenen Armen empfängst.
            Amen.
            """
        ),
        SpokenPrayer(
            title: "Anderen vergeben",
            category: .forgiveness,
            emoji: "🤝",
            text: """
            Herr, du hast mir so viel vergeben.
            Hilf mir nun, anderen zu vergeben.
            Ich lege allen Groll und Bitterkeit ab.
            Heile meine Wunden.
            Befreie mich von der Last der Vergangenheit.
            Lass mich in Frieden leben.
            Amen.
            """
        ),
        
        // Vaterunser
        SpokenPrayer(
            title: "Vaterunser",
            category: .morning,
            emoji: "✝️",
            text: """
            Vater unser im Himmel,
            geheiligt werde dein Name.
            Dein Reich komme.
            Dein Wille geschehe,
            wie im Himmel, so auf Erden.
            Unser tägliches Brot gib uns heute.
            Und vergib uns unsere Schuld,
            wie auch wir vergeben unseren Schuldigern.
            Und führe uns nicht in Versuchung,
            sondern erlöse uns von dem Bösen.
            Denn dein ist das Reich und die Kraft
            und die Herrlichkeit in Ewigkeit.
            Amen.
            """
        )
    ]
    
    static let englishPrayers: [SpokenPrayer] = [
        SpokenPrayer(title: "Morning Prayer", category: .morning, emoji: "🌅", text: "Lord, I thank you for this new day.\nI place everything that lies ahead in your hands.\nLead me, guide me, and use me.\nAmen."),
        SpokenPrayer(title: "The Lord's Prayer", category: .morning, emoji: "🙏", text: "Our Father in heaven,\nhallowed be your name.\nYour kingdom come,\nyour will be done,\non earth as it is in heaven.\nGive us this day our daily bread,\nand forgive us our debts,\nas we also have forgiven our debtors.\nAnd lead us not into temptation,\nbut deliver us from evil.\nFor yours is the kingdom and the power\nand the glory forever.\nAmen."),
        SpokenPrayer(title: "Evening Prayer", category: .evening, emoji: "🌙", text: "Lord, as the day ends, I seek your peace.\nWatch over me and my loved ones tonight.\nGrant us rest and refresh our souls.\nAmen."),
        SpokenPrayer(title: "Serenity Prayer", category: .peace, emoji: "🕊️", text: "God, grant me the serenity\nto accept the things I cannot change,\ncourage to change the things I can,\nand wisdom to know the difference.\nAmen."),
        SpokenPrayer(title: "Strength", category: .strength, emoji: "💪", text: "Lord, give me strength for today.\nHelp me to overcome my challenges.\nBe my rock and my fortress.\nAmen.")
    ]
    
    static let russianPrayers: [SpokenPrayer] = [
        SpokenPrayer(title: "Отче наш", category: .morning, emoji: "🙏", text: "Отче наш, сущий на небесах!\nДа святится имя Твое;\nда приидет Царствие Твое;\nда будет воля Твоя и на земле, как на небе;\nхлеб наш насущный дай нам на сей день;\nи прости нам долги наши,\nкак и мы прощаем должникам нашим;\nи не введи нас в искушение,\nно избавь нас от лукавого.\nАминь."),
        SpokenPrayer(title: "Утренняя молитва", category: .morning, emoji: "🌅", text: "Господи, благодарю Тебя за новый день.\nВверяю всё, что ждет меня, в Твои руки.\nВеди меня и направляй меня.\nАминь."),
        SpokenPrayer(title: "Вечерняя молитва", category: .evening, emoji: "🌙", text: "Господи, день подходит к концу.\nСпасибо за Твою защиту.\nДаруй нам мирный сон.\nАминь.")
    ]
    
    static let spanishPrayers: [SpokenPrayer] = [
        SpokenPrayer(title: "Padre Nuestro", category: .morning, emoji: "🙏", text: "Padre nuestro que estás en los cielos,\nsantificado sea tu nombre.\nVenga tu reino.\nHágase tu voluntad,\ncomo en el cielo, así también en la tierra.\nEl pan nuestro de cada día, dánoslo hoy.\nY perdónanos nuestras deudas,\ncomo también nosotros perdonamos a nuestros deudores.\nY no nos metas en tentación,\nmas líbranos del mal.\nAmén."),
        SpokenPrayer(title: "Oración de la Mañana", category: .morning, emoji: "🌅", text: "Señor, gracias por este nuevo día.\nPongo todo en tus manos.\nGuíame y úsame.\nAmén.")
    ]
    
    static let frenchPrayers: [SpokenPrayer] = [
        SpokenPrayer(title: "Notre Père", category: .morning, emoji: "🙏", text: "Notre Père, qui es aux cieux,\nque ton nom soit sanctifié,\nque ton règne vienne,\nque ta volonté soit faite sur la terre comme au ciel.\nDonne-nous aujourd’hui notre pain de ce jour.\nPardonne-nous nos offenses,\ncomme nous pardonnons aussi à ceux qui nous ont offensés.\nEt ne nous laisse pas entrer en tentation,\nmais délivre-nous du Mal.\nAmen."),
        SpokenPrayer(title: "Prière du Matin", category: .morning, emoji: "🌅", text: "Seigneur, merci pour ce nouveau jour.\nJe remets tout entre tes mains.\nGuide-moi.\nAmen.")
    ]

    // Dynamic prayers based on language
    static var allPrayers: [SpokenPrayer] {
        let lang = LocalizationManager.shared.language
        switch lang {
        case .german: return germanPrayers
        case .english: return englishPrayers
        case .russian: return russianPrayers
        case .spanish: return spanishPrayers
        case .french: return frenchPrayers
        }
    }
    
    static func forCategory(_ category: PrayerCategory) -> [SpokenPrayer] {
        allPrayers.filter { $0.category == category }
    }
    
    static func random() -> SpokenPrayer {
        allPrayers.randomElement() ?? germanPrayers.randomElement()!
    }
    
    // Get a random prayer matching the current mood
    static func forMood(_ mood: Mood) -> SpokenPrayer {
        let matchingCategories = mood.prayerCategories
        let matchingPrayers = allPrayers.filter { matchingCategories.contains($0.category) }
        return matchingPrayers.randomElement() ?? allPrayers.randomElement()!
    }
}

// Extend Mood to map to prayer categories
extension Mood {
    var prayerCategories: [SpokenPrayer.PrayerCategory] {
        switch self {
        case .joyful:
            return [.thanksgiving, .morning]
        case .sad:
            return [.strength, .forgiveness, .evening]
        case .anxious:
            return [.peace, .protection, .evening]
        case .thoughtful:
            return [.guidance, .morning]
        case .spiritual:
            return [.morning, .evening, .thanksgiving]
        case .hopeful:
            return [.guidance, .strength, .morning]
        }
    }
}
