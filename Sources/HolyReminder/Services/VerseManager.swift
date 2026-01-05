import Foundation

class VerseManager {
    static let shared = VerseManager()
    
    // Language -> Category -> Verses
    private var localizedVerses: [Language: [String: [BibleVerse]]] = [:]
    private var usedVerseIds: Set<UUID> = []
    
    private init() {
        print("🚀 VerseManager initializing (Multi-Language)")
        loadVerses()
    }
    
    private func loadVerses() {
        // German
        localizedVerses[.german] = [
            "praise": [
                BibleVerse(reference: "Psalm 100:4", text: "Geht ein zu seinen Toren mit Danken, zu seinen Vorhöfen mit Loben; dankt ihm, preist seinen Namen!", category: "praise"),
                BibleVerse(reference: "Philipper 4:4", text: "Freut euch im Herrn allezeit; abermals sage ich: Freut euch!", category: "praise"),
                BibleVerse(reference: "Psalm 118:24", text: "Dies ist der Tag, den der HERR gemacht hat; wir wollen uns freuen und fröhlich sein in ihm!", category: "praise")
            ],
            "comfort": [
                BibleVerse(reference: "Jesaja 41:10", text: "Fürchte dich nicht, denn ich bin mit dir; sei nicht ängstlich, denn ich bin dein Gott; ich stärke dich, ich helfe dir auch!", category: "comfort"),
                BibleVerse(reference: "Psalm 23:4", text: "Und wenn ich auch wanderte durchs Tal der Todesschatten, so fürchte ich kein Unglück, denn du bist bei mir.", category: "comfort"),
                BibleVerse(reference: "1. Petrus 5:7", text: "Alle eure Sorge werft auf ihn; denn er sorgt für euch.", category: "comfort")
            ],
            "peace": [
                BibleVerse(reference: "Philipper 4:6-7", text: "Sorgt euch um nichts; sondern in allem lasst durch Gebet und Flehen mit Danksagung eure Anliegen vor Gott kundwerden.", category: "peace"),
                BibleVerse(reference: "Johannes 14:27", text: "Frieden hinterlasse ich euch; meinen Frieden gebe ich euch. Euer Herz erschrecke nicht und verzage nicht!", category: "peace")
            ],
            "wisdom": [
                BibleVerse(reference: "Sprüche 3:5-6", text: "Vertraue auf den HERRN von ganzem Herzen und verlass dich nicht auf deinen Verstand.", category: "wisdom"),
                BibleVerse(reference: "Jakobus 1:5", text: "Wenn es aber jemand unter euch an Weisheit mangelt, so erbitte er sie von Gott, der allen gern gibt.", category: "wisdom")
            ],
            "spiritual": [
                BibleVerse(reference: "Galater 2:20", text: "Ich bin mit Christus gekreuzigt; und nun lebe ich, aber nicht mehr ich selbst, sondern Christus lebt in mir.", category: "spiritual"),
                BibleVerse(reference: "Johannes 15:5", text: "Ich bin der Weinstock, ihr seid die Reben. Wer in mir bleibt und ich in ihm, der bringt viel Frucht.", category: "spiritual")
            ],
            "hopeful": [
                BibleVerse(reference: "Römer 8:28", text: "Wir wissen aber, dass denen, die Gott lieben, alle Dinge zum Besten dienen.", category: "hopeful"),
                BibleVerse(reference: "Jeremia 29:11", text: "Denn ich weiß wohl, was ich für Gedanken über euch habe: Gedanken des Friedens und nicht des Leides.", category: "hopeful")
            ]
        ]
        
        // English
        localizedVerses[.english] = [
            "praise": [
                BibleVerse(reference: "Psalm 100:4", text: "Enter his gates with thanksgiving and his courts with praise; give thanks to him and praise his name.", category: "praise"),
                BibleVerse(reference: "Philippians 4:4", text: "Rejoice in the Lord always. I will say it again: Rejoice!", category: "praise")
            ],
            "comfort": [
                BibleVerse(reference: "Isaiah 41:10", text: "So do not fear, for I am with you; do not be dismayed, for I am your God. I will strengthen you and help you.", category: "comfort"),
                BibleVerse(reference: "Psalm 23:4", text: "Even though I walk through the darkest valley, I will fear no evil, for you are with me.", category: "comfort")
            ],
            "peace": [
                BibleVerse(reference: "Philippians 4:6-7", text: "Do not be anxious about anything, but in every situation, by prayer and petition, present your requests to God.", category: "peace"),
                BibleVerse(reference: "John 14:27", text: "Peace I leave with you; my peace I give you. Do not let your hearts be troubled.", category: "peace")
            ],
            "wisdom": [
                BibleVerse(reference: "Proverbs 3:5-6", text: "Trust in the LORD with all your heart and lean not on your own understanding.", category: "wisdom")
            ],
            "spiritual": [
                BibleVerse(reference: "Galatians 2:20", text: "I have been crucified with Christ and I no longer live, but Christ lives in me.", category: "spiritual")
            ]
        ]
        
        // Russian
        localizedVerses[.russian] = [
            "praise": [
                BibleVerse(reference: "Псалом 100:4", text: "Входите во врата Его со славословием, во дворы Его — с хвалою! Славьте Его, благословляйте имя Его!", category: "praise")
            ],
            "comfort": [
                BibleVerse(reference: "Исаия 41:10", text: "Не бойся, ибо Я с тобою; не смущайся, ибо Я Бог твой; Я укреплю тебя, и помогу тебе.", category: "comfort")
            ],
            "peace": [
                BibleVerse(reference: "Иоанна 14:27", text: "Мир оставляю вам, мир Мой даю вам; не так, как мир дает, Я даю вам. Да не смущается сердце ваше и да не устрашается.", category: "peace")
            ]
        ]
        
        // Spanish
        localizedVerses[.spanish] = [
            "praise": [
                BibleVerse(reference: "Salmos 100:4", text: "Entrad por sus puertas con acción de gracias, Por sus atrios con alabanza; Alabadle, bendecid su nombre.", category: "praise")
            ],
            "comfort": [
                BibleVerse(reference: "Isaías 41:10", text: "No temas, porque yo estoy contigo; no desmayes, porque yo soy tu Dios que te esfuerzo.", category: "comfort")
            ],
            "peace": [
                BibleVerse(reference: "Juan 14:27", text: "La paz os dejo, mi paz os doy; yo no os la doy como el mundo la da. No se turbe vuestro corazón, ni tenga miedo.", category: "peace")
            ]
        ]
        
        // French
        localizedVerses[.french] = [
            "praise": [
                BibleVerse(reference: "Psaumes 100:4", text: "Entrez dans ses portes avec des louanges, Dans ses parvis avec des cantiques! Célébrez-le, bénissez son nom!", category: "praise")
            ],
            "comfort": [
                BibleVerse(reference: "Ésaïe 41:10", text: "Ne crains rien, car je suis avec toi; Ne promène pas des regards inquiets, car je suis ton Dieu; Je te fortifie, je viens à ton secours.", category: "comfort")
            ],
            "peace": [
                BibleVerse(reference: "Jean 14:27", text: "Je vous laisse la paix, je vous donne ma paix. Je ne vous la donne pas comme le monde la donne. Que votre cœur ne se trouble point, et ne s'alarme point.", category: "peace")
            ]
        ]
    }
    
    func getRandomVerse(for mood: Mood) -> BibleVerse? {
        let currentLanguage = LocalizationManager.shared.language
        let category = mood.verseCategory
        
        // Get verses for current language, fallback to English if empty, then to German
        let versesForLang = localizedVerses[currentLanguage]?[category]
            ?? localizedVerses[.english]?[category]
            ?? localizedVerses[.german]?[category]
        
        guard let verses = versesForLang, !verses.isEmpty else {
            return nil
        }
        
        // Try to get an unused verse
        let unusedVerses = verses.filter { !usedVerseIds.contains($0.id) }
        
        if unusedVerses.isEmpty {
            // Reset used verses for this category
            verses.forEach { usedVerseIds.remove($0.id) }
            return verses.randomElement()
        }
        
        guard let verse = unusedVerses.randomElement() else { return nil }
        usedVerseIds.insert(verse.id)
        return verse
    }
}
