import Foundation

class VerseManager {
    static let shared = VerseManager()
    
    private var verses: [String: [BibleVerse]] = [:]
    private var usedVerseIds: Set<UUID> = []
    
    private init() {
        loadVerses()
    }
    
    private func loadVerses() {
        guard let url = Bundle.module.url(forResource: "verses", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("❌ Could not load verses.json")
            loadFallbackVerses()
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let rawVerses = try decoder.decode([String: [[String: String]]].self, from: data)
            
            for (category, verseList) in rawVerses {
                verses[category] = verseList.compactMap { dict in
                    guard let reference = dict["reference"],
                          let text = dict["text"] else { return nil }
                    return BibleVerse(reference: reference, text: text, category: category)
                }
            }
            
            print("✅ Loaded \(verses.values.flatMap { $0 }.count) verses")
        } catch {
            print("❌ Error parsing verses.json: \(error)")
            loadFallbackVerses()
        }
    }
    
    private func loadFallbackVerses() {
        // Fallback verses in case JSON loading fails
        verses = [
            "praise": [
                BibleVerse(reference: "Psalm 100:4", text: "Gehet zu seinen Toren ein mit Danken, zu seinen Vorhöfen mit Loben!", category: "praise")
            ],
            "comfort": [
                BibleVerse(reference: "Jesaja 41:10", text: "Fürchte dich nicht, ich bin mit dir; denn ich bin dein Gott.", category: "comfort")
            ],
            "peace": [
                BibleVerse(reference: "Philipper 4:6-7", text: "Sorgt euch um nichts, sondern lasst eure Bitten vor Gott kund werden!", category: "peace")
            ],
            "wisdom": [
                BibleVerse(reference: "Sprüche 3:5-6", text: "Verlass dich auf den Herrn von ganzem Herzen.", category: "wisdom")
            ],
            "spiritual": [
                BibleVerse(reference: "Galater 2:20", text: "Ich lebe, doch nun nicht ich, sondern Christus lebt in mir.", category: "spiritual")
            ]
        ]
    }
    
    func getRandomVerse(for mood: Mood) -> BibleVerse? {
        let category = mood.verseCategory
        guard let categoryVerses = verses[category], !categoryVerses.isEmpty else {
            return nil
        }
        
        // Try to get an unused verse
        let unusedVerses = categoryVerses.filter { !usedVerseIds.contains($0.id) }
        
        if unusedVerses.isEmpty {
            // Reset used verses for this category
            categoryVerses.forEach { usedVerseIds.remove($0.id) }
            return categoryVerses.randomElement()
        }
        
        guard let verse = unusedVerses.randomElement() else { return nil }
        usedVerseIds.insert(verse.id)
        return verse
    }
    
    func getAllCategories() -> [String] {
        return Array(verses.keys)
    }
    
    func getVerseCount(for category: String) -> Int {
        return verses[category]?.count ?? 0
    }
}
