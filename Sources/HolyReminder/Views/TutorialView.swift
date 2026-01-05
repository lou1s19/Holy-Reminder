import SwiftUI

struct TutorialView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var contentOpacity: Double = 1.0
    
    private let steps: [(icon: String, title: String, description: String)] = [
        ("book.closed.fill", "Willkommen bei Holy Reminder", "Erhalte regelmäßig stärkende Bibelverse und Gebetserinnerungen."),
        ("bell.badge.fill", "Benachrichtigungen aktivieren", "Damit du Verse und Erinnerungen erhältst, aktiviere bitte die Benachrichtigungen in den Systemeinstellungen."),
        ("heart.fill", "Wähle deine Stimmung", "Jeden Tag wählen Sie Ihre aktuelle Stimmung. Die App sendet Ihnen passende Verse."),
        ("gear", "Einstellungen anpassen", "Über das Menü-Icon können Sie die Häufigkeit und andere Optionen einstellen.")
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "0a0a12"),
                    Color(hex: "12121f"),
                    Color(hex: "1a1a2e")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "6366f1").opacity(0.1), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .blur(radius: 50)
                .offset(y: -60)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Icon
                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 60, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "a855f7"), Color(hex: "6366f1")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Title
                Text(steps[currentStep].title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                // Description
                Text(steps[currentStep].description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Special button for notifications step
                if currentStep == 1 {
                    Button(action: openNotificationSettings) {
                        HStack(spacing: 8) {
                            Image(systemName: "gearshape.fill")
                            Text("Einstellungen öffnen")
                        }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "a855f7"), Color(hex: "6366f1")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentStep ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                
                // Navigation buttons
                HStack(spacing: 20) {
                    if currentStep > 0 {
                        Button("Zurück") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if currentStep < steps.count - 1 {
                            withAnimation {
                                currentStep += 1
                            }
                        } else {
                            completeTutorial()
                        }
                    }) {
                        Text(currentStep == steps.count - 1 ? "Fertig" : "Weiter")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "a855f7"), Color(hex: "6366f1")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .opacity(contentOpacity)
        }
        .frame(width: 480, height: 520)
        .onAppear {
            // Make window float
            DispatchQueue.main.async {
                if let window = NSApp.windows.first(where: { $0.identifier?.rawValue.contains("tutorial") == true }) {
                    window.level = .floating
                    window.orderFrontRegardless()
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        }
    }
    
    private func openNotificationSettings() {
        // Try multiple schemes to ensure it works across macOS versions (including future "Tahoe")
        let schemes = [
            // Modern macOS (Ventura/Sonoma/Tahoe?) - Extension format
            "x-apple.systempreferences:com.apple.Notifications-Settings.extension?id=com.holyreminder.app",
            
            // Alternative modern format with slash
            "x-apple.systempreferences:com.apple.Notifications-Settings.extension/com.holyreminder.app",
            
            // Legacy/Fallback format
            "x-apple.systempreferences:com.apple.preference.notifications?id=com.holyreminder.app",
            
            // Direct path format (sometimes works)
            "x-apple.systempreferences:com.apple.preference.notifications/com.holyreminder.app"
        ]
        
        for scheme in schemes {
            if let url = URL(string: scheme) {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    private func completeTutorial() {
        // Mark tutorial as complete
        UserDefaults.standard.set(true, forKey: "tutorialCompleted")
        
        withAnimation(.easeOut(duration: 0.5)) {
            contentOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
            if let window = NSApp.windows.first(where: { $0.identifier?.rawValue.contains("tutorial") == true }) {
                window.close()
            }
        }
    }
}

#if DEBUG
struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView()
            .environmentObject(AppState.shared)
    }
}
#endif
