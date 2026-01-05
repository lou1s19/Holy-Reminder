import Foundation

enum Language: String, CaseIterable, Codable, Identifiable {
    case german = "de"
    case english = "en"
    case russian = "ru"
    case spanish = "es"
    case french = "fr"
    
    var id: String { rawValue }
    
    static func detect() -> Language {
        let preferred = Locale.preferredLanguages.first?.prefix(2).lowercased() ?? "en"
        return Language(rawValue: String(preferred)) ?? .english
    }
    
    var displayName: String {
        switch self {
        case .german: return "Deutsch"
        case .english: return "English"
        case .russian: return "Русский"
        case .spanish: return "Español"
        case .french: return "Français"
        }
    }
}

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var language: Language {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "selectedLanguageCode")
        }
    }
    
    init() {
        if let stored = UserDefaults.standard.string(forKey: "selectedLanguageCode"),
           let lang = Language(rawValue: stored) {
            self.language = lang
        } else {
            self.language = Language.detect()
        }
    }
    
    // UI Strings Map
    private let strings: [String: [Language: String]] = [
        // Menu & General
        "menu_mood": [
            .german: "Stimmung ändern", .english: "Change Mood", .russian: "Изменить настроение", .spanish: "Cambiar estado de ánimo", .french: "Changer d'humeur"
        ],
        "menu_prayers": [
            .german: "Gebete mitsprechen", .english: "Spoken Prayers", .russian: "Молитвы вслух", .spanish: "Oraciones habladas", .french: "Prières parlées"
        ],
        "menu_remind_now": [
            .german: "Jetzt erinnern", .english: "Remind Now", .russian: "Напомнить сейчас", .spanish: "Recordar ahora", .french: "Rappeler maintenant"
        ],
        "menu_pause": [
            .german: "Pause (1h)", .english: "Pause (1h)", .russian: "Пауза (1ч)", .spanish: "Pausa (1h)", .french: "Pause (1h)"
        ],
        "menu_resume": [
            .german: "Fortsetzen", .english: "Resume", .russian: "Продолжить", .spanish: "Reanudar", .french: "Reprendre"
        ],
        "menu_settings": [
            .german: "Einstellungen...", .english: "Settings...", .russian: "Настройки...", .spanish: "Ajustes...", .french: "Réglages..."
        ],
        "menu_quit": [
            .german: "Beenden", .english: "Quit", .russian: "Выход", .spanish: "Salir", .french: "Quitter"
        ],
        "menu_verse_title": [
            .german: "📖 Aktueller Vers", .english: "📖 Current Verse", .russian: "📖 Текущий стих", .spanish: "📖 Versículo actual", .french: "📖 Verset actuel"
        ],
        "menu_no_verse": [
            .german: "Noch kein Vers empfangen", .english: "No verse received yet", .russian: "Стихов пока нет", .spanish: "Ningún versículo aún", .french: "Aucun verset reçu"
        ],
        "menu_next_reminder": [
            .german: "Nächste Erinnerung:", .english: "Next reminder:", .russian: "Следующее:", .spanish: "Siguiente:", .french: "Prochain:"
        ],
        "menu_paused": [
            .german: "Erinnerungen pausiert", .english: "Reminders paused", .russian: "Напоминания на паузе", .spanish: "Pausado", .french: "En pause"
        ],
        "menu_pause_action": [
            .german: "Pausieren", .english: "Pause", .russian: "Пауза", .spanish: "Pausar", .french: "Pause"
        ],
        "menu_activate_notifications": [
            .german: "Mitteilungen aktivieren", .english: "Enable Notifications", .russian: "Включить уведомления", .spanish: "Activar notificaciones", .french: "Activer les notifications"
        ],
        "menu_copy_help": [
            .german: "Vers kopieren", .english: "Copy Verse", .russian: "Копировать", .spanish: "Copiar", .french: "Copier"
        ],
        "menu_support": [
           .german: "Unterstützen", .english: "Support", .russian: "Поддержать", .spanish: "Apoyar", .french: "Soutenir"
        ],
        
        // Settings - Tabs
        "settings_tab_general": [
            .german: "Allgemein", .english: "General", .russian: "Общие", .spanish: "General", .french: "Général"
        ],
        "settings_tab_appearance": [
            .german: "Aussehen", .english: "Appearance", .russian: "Вид", .spanish: "Apariencia", .french: "Apparence"
        ],
        "settings_tab_notifications": [
            .german: "Erinnerungen", .english: "Notifications", .russian: "Уведомления", .spanish: "Notificaciones", .french: "Notifications"
        ],
        "settings_tab_about": [
            .german: "Über", .english: "About", .russian: "О программе", .spanish: "Acerca de", .french: "À propos"
        ],
        
        // Settings - General
        "settings_language": [
            .german: "Sprache", .english: "Language", .russian: "Язык", .spanish: "Idioma", .french: "Langue"
        ],
        "settings_autostart": [
            .german: "Bei Anmeldung starten", .english: "Launch at login", .russian: "Запускать при входе", .spanish: "Iniciar al arrancar", .french: "Lancer au démarrage"
        ],
        "settings_autostart_header": [
            .german: "Systemstart", .english: "Startup", .russian: "Автозапуск", .spanish: "Inicio", .french: "Démarrage"
        ],
        
        // Settings - Appearance
        "settings_icon": [
            .german: "Menüleisten-Icon", .english: "Menu Bar Icon", .russian: "Иконка меню", .spanish: "Icono de menú", .french: "Icône de menu"
        ],
        "settings_icon_desc": [
            .german: "Wähle ein Icon für die Menüleiste.", .english: "Choose an icon for the menu bar.", .russian: "Выберите иконку.", .spanish: "Elige un icono.", .french: "Choisissez une icône."
        ],
        
        // Settings - Notifications
        "settings_interval": [
            .german: "Erinnerungs-Intervall", .english: "Reminder Interval", .russian: "Интервал напоминаний", .spanish: "Intervalo", .french: "Intervalle"
        ],
        "settings_frequency_header": [
            .german: "Erinnerungs-Frequenz", .english: "Frequency", .russian: "Частота", .spanish: "Frecuencia", .french: "Fréquence"
        ],
        "settings_frequency_footer": [
            .german: "Wie oft möchtest du erinnert werden?", .english: "How often do you want to be reminded?", .russian: "Как часто напоминать?", .spanish: "¿Con qué frecuencia?", .french: "À quelle fréquence ?"
        ],
        "settings_sounds_header": [
            .german: "Töne", .english: "Sounds", .russian: "Звуки", .spanish: "Sonidos", .french: "Sons"
        ],
        "settings_sound_notification": [
            .german: "Benachrichtigungston", .english: "Notification Sound", .russian: "Звук уведомления", .spanish: "Sonido de notificación", .french: "Son de notification"
        ],
        "settings_sound_prayer": [
            .german: "Amen-Sound abspielen", .english: "Play Amen Sound", .russian: "Звук 'Аминь'", .spanish: "Sonido Amén", .french: "Son Amen"
        ],
        "settings_prayers_header": [
            .german: "Gebetserinnerungen", .english: "Prayer Reminders", .russian: "Напоминания о молитве", .spanish: "Recordatorios de oración", .french: "Rappels de prière"
        ],
        "settings_prayers_enable": [
            .german: "Gebetserinnerungen aktivieren", .english: "Enable Prayer Reminders", .russian: "Включить напоминания о молитве", .spanish: "Activar recordatorios", .french: "Activer les rappels"
        ],
        "settings_ratio_verse": [
            .german: "Vers", .english: "Verse", .russian: "Стих", .spanish: "Versículo", .french: "Verset"
        ],
        "settings_ratio_prayer": [
            .german: "Gebet", .english: "Prayer", .russian: "Молитва", .spanish: "Oración", .french: "Prière"
        ],
        "settings_ratio_label": [
            .german: "Verhältnis", .english: "Ratio", .russian: "Соотношение", .spanish: "Proporción", .french: "Ratio"
        ],

        // Warnings
        "warning_title": [
            .german: "Wichtig", .english: "Important", .russian: "Важно", .spanish: "Importante", .french: "Important"
        ],
        "warning_notifications_disabled": [
            .german: "Benachrichtigungen deaktiviert!", .english: "Notifications disabled!", .russian: "Уведомления выключены!", .spanish: "¡Notificaciones desactivadas!", .french: "Notifications désactivées !"
        ],
        "warning_notifications_desc": [
            .german: "Aktiviere sie in den Systemeinstellungen.", .english: "Enable in System Settings.", .russian: "Включите в настройках.", .spanish: "Activar en Ajustes.", .french: "Activer dans les réglages."
        ],
        "button_open": [
            .german: "Öffnen", .english: "Open", .russian: "Открыть", .spanish: "Abrir", .french: "Ouvrir"
        ],
        "button_activate": [
            .german: "Aktivieren", .english: "Enable", .russian: "Включить", .spanish: "Activar", .french: "Activer"
        ],
        "warning_autostart_title": [
            .german: "Autostart empfohlen!", .english: "Autostart recommended!", .russian: "Автозапуск!", .spanish: "Autoarranque!", .french: "Démarrage auto !"
        ],
        "warning_autostart_desc": [
            .german: "Aktiviere den Autostart, damit Holy Reminder beim Mac-Start automatisch läuft.", .english: "Enable autostart so Holy Reminder runs automatically.", .russian: "Включите автозапуск.", .spanish: "Activa el inicio automático.", .french: "Activez le démarrage auto."
        ],
        "warning_recommendation": [
            .german: "Empfehlung", .english: "Recommendation", .russian: "Рекомендация", .spanish: "Recomendación", .french: "Recommandation"
        ],
        "settings_sound_prayer_desc": [
            .german: "Nach dem Mitsprechen eines Gebets", .english: "After praying along", .russian: "После молитвы", .spanish: "Tras orar", .french: "Après la prière"
        ],
        "settings_prayers_desc": [
            .german: "Erhalte abwechselnd Verse und Gebete.", .english: "Receive verses and prayers alternately.", .russian: "Стихи и молитвы чередуются.", .spanish: "Versos y oraciones alternados.", .french: "Versets et prières alternés."
        ],
        "settings_ratio_desc": [
            .german: "Entscheide, wie oft Verse im Vergleich zu Gebeten erscheinen.", .english: "Decide how often verses appear vs prayers.", .russian: "Настройте частоту стихов и молитв.", .spanish: "Ajusta la frecuencia.", .french: "Réglez la fréquence."
        ],
        "about_title": [
            .german: "Über Holy Reminder", .english: "About Holy Reminder", .russian: "О программе", .spanish: "Acerca de", .french: "À propos"
        ],
        "about_created_by": [
            .german: "Erstellt von", .english: "Created by", .russian: "Создано", .spanish: "Creado por", .french: "Créé par"
        ],
        "about_version": [
            .german: "Version", .english: "Version", .russian: "Версия", .spanish: "Versión", .french: "Version"
        ],
        "about_desc": [
            .german: "Tägliche Bibelerinnerungen für deinen Mac", .english: "Daily Bible reminders for your Mac", .russian: "Ежедневные напоминания", .spanish: "Recordatorios diarios", .french: "Rappels quotidiens"
        ],
        "settings_quiet_hours_header": [
            .german: "Stille Zeiten", .english: "Quiet Hours", .russian: "Тихие часы", .spanish: "Horas de silencio", .french: "Heures calmes"
        ],
        "settings_quiet_hours_enable": [
            .german: "Stille Zeiten aktivieren", .english: "Enable Quiet Hours", .russian: "Включить", .spanish: "Activar", .french: "Activer"
        ],
        "settings_quiet_hours_desc": [
            .german: "Während der stillen Zeit werden keine Benachrichtigungen gesendet.", .english: "No notifications during quiet hours.", .russian: "Без уведомлений.", .spanish: "Sin notificaciones.", .french: "Pas de notifications."
        ],
        "quiet_from": [
            .german: "Von", .english: "From", .russian: "С", .spanish: "De", .french: "De"
        ],
        "quiet_to": [
            .german: "bis", .english: "to", .russian: "до", .spanish: "a", .french: "à"
        ],
        "button_check_update": [
            .german: "Nach Updates suchen", .english: "Check for Updates", .russian: "Проверить обновления", .spanish: "Buscar actualizaciones", .french: "Vérifier les MAJ"
        ],
        "settings_auto_update": [
            .german: "Automatisch nach Updates suchen", .english: "Check automatically", .russian: "Автоматически проверять", .spanish: "Comprobar automáticamente", .french: "Vérifier automatiquement"
        ],
        "button_reset": [
            .german: "Daten zurücksetzen", .english: "Reset Data", .russian: "Сбросить данные", .spanish: "Restablecer datos", .french: "Réinitialiser"
        ],
        
        // Prayer Window
        "prayer_window_title": [
            .german: "Gebete zum Mitsprechen", .english: "Spoken Prayers", .russian: "Молитвы", .spanish: "Oraciones", .french: "Prières"
        ],
        "prayer_back": [
            .german: "Zurück", .english: "Back", .russian: "Назад", .spanish: "Atrás", .french: "Retour"
        ],
        "prayer_enter_next": [
            .german: "Enter für Weiter", .english: "Enter for Next", .russian: "Enter для далее", .spanish: "Enter para siguiente", .french: "Entrée pour suivant"
        ],
        "prayer_enter_amen": [
            .german: "Enter für Amen", .english: "Enter for Amen", .russian: "Enter для Аминь", .spanish: "Enter para Amén", .french: "Entrée pour Amen"
        ],
        "prayer_next": [
            .german: "Weiter", .english: "Next", .russian: "Далее", .spanish: "Siguiente", .french: "Suivant"
        ],
        "prayer_amen": [
            .german: "Amen", .english: "Amen", .russian: "Аминь", .spanish: "Amén", .french: "Amen"
        ],
        "close": [
            .german: "Schließen", .english: "Close", .russian: "Закрыть", .spanish: "Cerrar", .french: "Fermer"
        ],
        
        // Mood Selection
        "mood_selection_title": [
            .german: "Wie fühlst du dich gerade?", .english: "How are you feeling?", .russian: "Как вы себя чувствуете?", .spanish: "¿Cómo te sientes?", .french: "Comment vous sentez-vous ?"
        ],
        
        // Moods
        "mood_joyful": [
            .german: "Dankbar & Freudig", .english: "Joyful & Thankful", .russian: "Радостный", .spanish: "Alegre y Agradecido", .french: "Joyeux et Reconnaissant"
        ],
        // Greetings
        "greeting_morning": [
            .german: "Guten Morgen", .english: "Good morning", .russian: "Доброе утро", .spanish: "Buenos días", .french: "Bonjour"
        ],
        "greeting_afternoon": [
            .german: "Guten Tag", .english: "Good afternoon", .russian: "Добрый день", .spanish: "Buenas tardes", .french: "Bon après-midi"
        ],
        "greeting_evening": [
            .german: "Guten Abend", .english: "Good evening", .russian: "Добрый вечер", .spanish: "Buenas noches", .french: "Bonsoir"
        ],
        "greeting_night": [
            .german: "Gute Nacht", .english: "Good night", .russian: "Доброй ночи", .spanish: "Buenas noches", .french: "Bonne nuit"
        ],
        "mood_sad": [
            .german: "Traurig & Schwer", .english: "Sad & Heavy", .russian: "Грустный", .spanish: "Triste", .french: "Triste"
        ],
        "mood_anxious": [
            .german: "Ängstlich & Gestresst", .english: "Anxious & Stressed", .russian: "Тревожный", .spanish: "Ansioso", .french: "Anxieux"
        ],
        "mood_thoughtful": [
            .german: "Nachdenklich", .english: "Thoughtful", .russian: "Задумчивый", .spanish: "Pensativo", .french: "Pensif"
        ],
        "mood_spiritual": [
            .german: "Geistlich hungrig", .english: "Spiritually Hungry", .russian: "Духовный", .spanish: "Espiritual", .french: "Spirituel"
        ],
        "mood_hopeful": [
            .german: "Hoffnungsvoll", .english: "Hopeful", .russian: "С надеждой", .spanish: "Esperanzado", .french: "Plein d'espoir"
        ],
        
        "mood_desc_joyful": [
            .german: "Du wirst Lobpreis- und Dankbarkeitsverse erhalten", .english: "You will receive praise and thanksgiving verses", .russian: "Стихи хвалы и благодарности", .spanish: "Versos de alabanza", .french: "Versets de louange"
        ],
        "mood_desc_sad": [
            .german: "Du wirst tröstende und aufbauende Verse erhalten", .english: "You will receive comforting verses", .russian: "Утешительные стихи", .spanish: "Versos de consuelo", .french: "Versets de réconfort"
        ],
        "mood_desc_anxious": [
           .german: "Du wirst Verse über Frieden und Geborgenheit erhalten", .english: "You will receive verses about peace", .russian: "Стихи о мире", .spanish: "Versos de paz", .french: "Versets de paix"
        ],
        "mood_desc_thoughtful": [
            .german: "Du wirst Weisheits- und Lebensverse erhalten", .english: "Wisdom and life verses", .russian: "Стихи мудрости", .spanish: "Versos de sabiduría", .french: "Versets de sagesse"
        ],
        "mood_desc_spiritual": [
            .german: "Du wirst tiefgehende geistliche Verse erhalten", .english: "Deep spiritual verses", .russian: "Духовные стихи", .spanish: "Versos espirituales", .french: "Versets spirituels"
        ],
        "mood_desc_hopeful": [
            .german: "Du wirst Verse über Hoffnung und Zukunft erhalten", .english: "Verses about hope and future", .russian: "Стихи о надежде", .spanish: "Versos de esperanza", .french: "Versets d'espoir"
        ],
        
        // Notifications
        "notification_prayer_title": [
            .german: "Zeit zum Beten", .english: "Time to Pray", .russian: "Время молиться", .spanish: "Hora de orar", .french: "L'heure de prier"
        ],
        "notification_prayer_body": [
            .german: "Tippe zum Mitsprechen", .english: "Tap to pray along", .russian: "Нажмите, чтобы молиться", .spanish: "Toca para orar", .french: "Appuyez pour prier"
        ]
    ]
    
    func string(_ key: String) -> String {
        return strings[key]?[language] ?? strings[key]?[.english] ?? key
    }
    
    func setLanguage(_ lang: Language) {
        self.language = lang
    }
}

// Global helper
func L10n(_ key: String) -> String {
    LocalizationManager.shared.string(key)
}
