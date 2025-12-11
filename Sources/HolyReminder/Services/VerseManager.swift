import Foundation

class VerseManager {
    static let shared = VerseManager()
    
    private var verses: [String: [BibleVerse]] = [:]
    private var usedVerseIds: Set<UUID> = []
    
    private init() {
        print("🚀 VerseManager initializing (NEW VERSION)")
        loadVerses()
    }
    
    private func loadVerses() {
        // Use embedded verses to avoid Bundle.module crash
        // The SPM-generated Bundle.module extension crashes on re-access
        loadEmbeddedVerses()
        print("✅ Loaded \(verses.values.flatMap { $0 }.count) embedded verses")
    }
    
    private func loadEmbeddedVerses() {
        verses = [
            "praise": [
                BibleVerse(reference: "Psalm 100:4", text: "Geht ein zu seinen Toren mit Danken, zu seinen Vorhöfen mit Loben; dankt ihm, preist seinen Namen!", category: "praise"),
                BibleVerse(reference: "Psalm 150:6", text: "Alles, was Odem hat, lobe den HERRN! Hallelujah!", category: "praise"),
                BibleVerse(reference: "Philipper 4:4", text: "Freut euch im Herrn allezeit; abermals sage ich: Freut euch!", category: "praise"),
                BibleVerse(reference: "Psalm 103:1", text: "Lobe den HERRN, meine Seele, und alles, was in mir ist, seinen heiligen Namen!", category: "praise"),
                BibleVerse(reference: "Psalm 118:24", text: "Dies ist der Tag, den der HERR gemacht hat; wir wollen uns freuen und fröhlich sein in ihm!", category: "praise"),
                BibleVerse(reference: "Psalm 34:2", text: "Ich will den HERRN preisen allezeit, sein Lob soll immerzu in meinem Mund sein.", category: "praise")
            ],
            "comfort": [
                BibleVerse(reference: "Jesaja 41:10", text: "Fürchte dich nicht, denn ich bin mit dir; sei nicht ängstlich, denn ich bin dein Gott; ich stärke dich, ich helfe dir auch!", category: "comfort"),
                BibleVerse(reference: "Psalm 23:4", text: "Und wenn ich auch wanderte durchs Tal der Todesschatten, so fürchte ich kein Unglück, denn du bist bei mir.", category: "comfort"),
                BibleVerse(reference: "Matthäus 11:28", text: "Kommt her zu mir alle, die ihr mühselig und beladen seid, so will ich euch erquicken!", category: "comfort"),
                BibleVerse(reference: "Römer 8:28", text: "Wir wissen aber, dass denen, die Gott lieben, alle Dinge zum Besten dienen.", category: "comfort"),
                BibleVerse(reference: "Psalm 34:19", text: "Der HERR ist nahe denen, die zerbrochenen Herzens sind, und er hilft denen, die zerschlagenen Geistes sind.", category: "comfort"),
                BibleVerse(reference: "1. Petrus 5:7", text: "Alle eure Sorge werft auf ihn; denn er sorgt für euch.", category: "comfort")
            ],
            "peace": [
                BibleVerse(reference: "Philipper 4:6-7", text: "Sorgt euch um nichts; sondern in allem lasst durch Gebet und Flehen mit Danksagung eure Anliegen vor Gott kundwerden.", category: "peace"),
                BibleVerse(reference: "Johannes 14:27", text: "Frieden hinterlasse ich euch; meinen Frieden gebe ich euch. Euer Herz erschrecke nicht und verzage nicht!", category: "peace"),
                BibleVerse(reference: "Jesaja 26:3", text: "Einem festen Herzen bewahrst du den Frieden, den Frieden, weil es auf dich vertraut.", category: "peace"),
                BibleVerse(reference: "Psalm 46:11", text: "Seid still und erkennt, dass ich Gott bin!", category: "peace"),
                BibleVerse(reference: "Römer 15:13", text: "Der Gott der Hoffnung aber erfülle euch mit aller Freude und mit Frieden im Glauben.", category: "peace"),
                BibleVerse(reference: "2. Timotheus 1:7", text: "Denn Gott hat uns nicht einen Geist der Furchtsamkeit gegeben, sondern der Kraft und der Liebe und der Zucht.", category: "peace")
            ],
            "wisdom": [
                BibleVerse(reference: "Sprüche 3:5-6", text: "Vertraue auf den HERRN von ganzem Herzen und verlass dich nicht auf deinen Verstand.", category: "wisdom"),
                BibleVerse(reference: "Jakobus 1:5", text: "Wenn es aber jemand unter euch an Weisheit mangelt, so erbitte er sie von Gott, der allen gern gibt.", category: "wisdom"),
                BibleVerse(reference: "Psalm 119:105", text: "Dein Wort ist meines Fußes Leuchte und ein Licht auf meinem Weg.", category: "wisdom"),
                BibleVerse(reference: "Jeremia 29:11", text: "Denn ich weiß, was für Gedanken ich über euch habe, spricht der HERR, Gedanken des Friedens und nicht des Unheils.", category: "wisdom"),
                BibleVerse(reference: "Psalm 32:8", text: "Ich will dich unterweisen und dir den Weg zeigen, auf dem du wandeln sollst.", category: "wisdom"),
                BibleVerse(reference: "Sprüche 16:3", text: "Befiehl dem HERRN deine Werke, und deine Pläne werden zustande kommen.", category: "wisdom")
            ],
            "spiritual": [
                BibleVerse(reference: "Galater 2:20", text: "Ich bin mit Christus gekreuzigt; und nun lebe ich, aber nicht mehr ich selbst, sondern Christus lebt in mir.", category: "spiritual"),
                BibleVerse(reference: "Johannes 15:5", text: "Ich bin der Weinstock, ihr seid die Reben. Wer in mir bleibt und ich in ihm, der bringt viel Frucht.", category: "spiritual"),
                BibleVerse(reference: "Epheser 3:16", text: "Dass er euch nach dem Reichtum seiner Herrlichkeit gebe, durch seinen Geist mit Kraft gestärkt zu werden.", category: "spiritual"),
                BibleVerse(reference: "Psalm 42:2", text: "Wie ein Hirsch lechzt nach Wasserbächen, so lechzt meine Seele, o Gott, nach dir!", category: "spiritual"),
                BibleVerse(reference: "Galater 5:22", text: "Die Frucht des Geistes aber ist Liebe, Freude, Friede, Langmut, Freundlichkeit, Güte, Treue, Sanftmut.", category: "spiritual"),
                BibleVerse(reference: "Johannes 4:14", text: "Wer aber von dem Wasser trinkt, das ich ihm geben werde, den wird in Ewigkeit nicht dürsten.", category: "spiritual")
            ],
            "hopeful": [
                BibleVerse(reference: "Römer 8:28", text: "Wir wissen aber, dass denen, die Gott lieben, alle Dinge zum Besten dienen.", category: "hopeful"),
                BibleVerse(reference: "Jeremia 29:11", text: "Denn ich weiß wohl, was ich für Gedanken über euch habe: Gedanken des Friedens und nicht des Leides.", category: "hopeful"),
                BibleVerse(reference: "Psalm 27:1", text: "Der HERR ist mein Licht und mein Heil, vor wem sollte ich mich fürchten?", category: "hopeful"),
                BibleVerse(reference: "Jesaja 40:31", text: "Aber die auf den HERRN harren, kriegen neue Kraft, dass sie auffahren mit Flügeln wie Adler.", category: "hopeful"),
                BibleVerse(reference: "Psalm 30:6", text: "Am Abend kehrt das Weinen ein und am Morgen der Jubel.", category: "hopeful"),
                BibleVerse(reference: "Hebräer 11:1", text: "Es ist aber der Glaube eine feste Zuversicht auf das, was man hofft, eine Überzeugung von Tatsachen, die man nicht sieht.", category: "hopeful")
            ]
        ]
    }
    
    private func loadFallbackVerses() {
        // Fallback verses in case JSON loading fails
        verses = [
            "praise": [
                BibleVerse(reference: "Psalm 100:4", text: "Geht ein zu seinen Toren mit Danken, zu seinen Vorhöfen mit Loben!", category: "praise")
            ],
            "comfort": [
                BibleVerse(reference: "Jesaja 41:10", text: "Fürchte dich nicht, denn ich bin mit dir; sei nicht ängstlich, denn ich bin dein Gott.", category: "comfort")
            ],
            "peace": [
                BibleVerse(reference: "Philipper 4:6-7", text: "Sorgt euch um nichts; sondern in allem lasst durch Gebet und Flehen mit Danksagung eure Anliegen vor Gott kundwerden.", category: "peace")
            ],
            "wisdom": [
                BibleVerse(reference: "Sprüche 3:5-6", text: "Vertraue auf den HERRN von ganzem Herzen und verlass dich nicht auf deinen Verstand.", category: "wisdom")
            ],
            "spiritual": [
                BibleVerse(reference: "Galater 2:20", text: "Ich bin mit Christus gekreuzigt; und nun lebe ich, aber nicht mehr ich selbst, sondern Christus lebt in mir.", category: "spiritual")
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
