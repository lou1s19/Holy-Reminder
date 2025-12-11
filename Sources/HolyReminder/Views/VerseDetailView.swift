import SwiftUI

struct VerseDetailView: View {
    let verse: BibleVerse
    let mood: Mood
    @State private var showAmen = false
    @State private var contentScale: CGFloat = 0.95
    @State private var contentOpacity: Double = 0
    @State private var lineOffset: CGFloat = 50
    @State private var isClosing = false
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(hex: "0f0f1a"),
                    Color(hex: "1a1a2e"),
                    Color(hex: "1f1f3a")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Subtle animated glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [mood.accentColor.opacity(0.15), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .blur(radius: 50)
                .offset(y: -50)
            
            // Content
            VStack(spacing: 24) {
                Spacer()
                
                // Minimal book icon
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(mood.accentColor.opacity(0.8))
                    .scaleEffect(contentScale)
                
                // Reference with underline animation
                VStack(spacing: 8) {
                    Text(verse.reference)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    // Animated line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: mood.gradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: lineOffset, height: 2)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3), value: lineOffset)
                }
                
                // Verse text with staggered reveal
                Text(verse.text)
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(10)
                    .padding(.horizontal, 50)
                
                Spacer()
                
                // Minimal hint
                HStack(spacing: 6) {
                    Image(systemName: "return")
                        .font(.system(size: 12, weight: .medium))
                    Text("Enter für Amen")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                }
                .foregroundStyle(.white.opacity(0.4))
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(
                    ZStack {
                        Capsule()
                            .fill(Color.white.opacity(0.05))
                        Capsule()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    }
                )
                
                // Close button - minimal
                Button(action: closeWindow) {
                    Text("Schließen")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 24)
            }
            .scaleEffect(contentScale)
            .opacity(contentOpacity)
            
            // Amen overlay
            if showAmen {
                AmenOverlayView(isShowing: $showAmen, onComplete: {
                    closeWindow()
                })
            }
            
            // Invisible button to capture Enter key safely
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showAmen = true
                    if AppState.shared.playPrayerSound {
                        NSSound(named: "Glass")?.play()
                    }
                }
            }) {
                EmptyView()
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.defaultAction) // Triggers on Enter
        }
        .frame(width: 500, height: 420)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                contentScale = 1.0
                contentOpacity = 1.0
            }
            // Trigger line animation
            lineOffset = 120
        }
// KeyEventHandler removed to eliminate potential crash source
// struct KeyEventHandler ...
// class KeyCaptureView ...
    
    }
    
    private func closeWindow() {
        guard !isClosing else { return }
        isClosing = true
        
        // Fade out animation
        withAnimation(.easeOut(duration: 0.4)) {
            contentOpacity = 0
            contentScale = 0.9
        }
        
        // Close after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            VerseDetailWindowController.shared.closeWindow()
        }
    }
}

// Window controller for showing verse detail
class VerseDetailWindowController {
    static let shared = VerseDetailWindowController()
    private var window: NSWindow?
    private var isClosing = false
    
    func showVerse(_ verse: BibleVerse, mood: Mood) {
        // If already closing, wait a bit
        if isClosing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.showVerse(verse, mood: mood)
            }
            return
        }
        
        // Close existing window first
        if let existingWindow = window {
            print("🪟 Closing existing window")
            existingWindow.close()
            window = nil
        }
        
        let contentView = VerseDetailView(verse: verse, mood: mood)
        let hostingView = NSHostingView(rootView: contentView)
        
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 420),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        newWindow.contentView = hostingView
        newWindow.titlebarAppearsTransparent = true
        newWindow.titleVisibility = .hidden
        newWindow.isMovableByWindowBackground = true
        newWindow.backgroundColor = .clear
        newWindow.level = .floating
        newWindow.hidesOnDeactivate = false
        
        // CRITICAL FIX: Prevent double-free crash
        // If true (default), window releases itself on close, but we hold a strong ref
        newWindow.isReleasedWhenClosed = false 
        
        newWindow.center()
        
        // Use orderFrontRegardless instead of makeKeyAndOrderFront + activate
        newWindow.orderFrontRegardless()
        
        self.window = newWindow
        print("🪟 New window created and shown")
    }
    
    func closeWindow() {
        guard !isClosing else { return }
        isClosing = true
        
        if let existingWindow = window {
            print("🪟 closeWindow called")
            existingWindow.close()
            window = nil
        }
        
        // Reset closing flag after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.isClosing = false
        }
    }
}

// Prayer detail view - minimalist
struct PrayerDetailView: View {
    let reminder: PrayerReminder
    @State private var showAmen = false
    @State private var contentScale: CGFloat = 0.95
    @State private var contentOpacity: Double = 0
    @State private var isClosing = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "0f0f1a"),
                    Color(hex: "1a1a2e"),
                    Color(hex: "251a3d")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "a855f7").opacity(0.15), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .blur(radius: 40)
                .offset(y: -40)
            
            VStack(spacing: 24) {
                Spacer()
                
                // Minimal icon
                Image(systemName: "hands.clap.fill")
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(Color(hex: "a855f7").opacity(0.8))
                
                Text(reminder.title)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(reminder.message)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "return")
                        .font(.system(size: 12, weight: .medium))
                    Text("Enter für Amen")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                }
                .foregroundStyle(.white.opacity(0.4))
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(
                    ZStack {
                        Capsule()
                            .fill(Color.white.opacity(0.05))
                        Capsule()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    }
                )
                
                Button(action: closeWindow) {
                    Text("Schließen")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 24)
            }
            .scaleEffect(contentScale)
            .opacity(contentOpacity)
            
            if showAmen {
                AmenOverlayView(isShowing: $showAmen, onComplete: {
                    closeWindow()
                })
            }
            
            // Invisible button to capture Enter key safely
            Button(action: {
                withAnimation {
                    showAmen = true
                    if AppState.shared.playPrayerSound {
                        NSSound(named: "Glass")?.play()
                    }
                }
            }) {
                EmptyView()
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.defaultAction)
        }
        .frame(width: 460, height: 380)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                contentScale = 1.0
                contentOpacity = 1.0
            }
        }
        // KeyEventHandler removed
    }
    
    private func closeWindow() {
        guard !isClosing else { return }
        isClosing = true
        
        withAnimation(.easeOut(duration: 0.4)) {
            contentOpacity = 0
            contentScale = 0.9
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            PrayerDetailWindowController.shared.closeWindow()
        }
    }
}

class PrayerDetailWindowController {
    static let shared = PrayerDetailWindowController()
    private var window: NSWindow?
    private var isClosing = false
    
    func showPrayer(_ reminder: PrayerReminder) {
        // If already closing, wait a bit
        if isClosing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.showPrayer(reminder)
            }
            return
        }
        
        // Close existing window first
        if let existingWindow = window {
            print("🪟 Closing existing prayer window")
            existingWindow.close()
            window = nil
        }
        
        let contentView = PrayerDetailView(reminder: reminder)
        let hostingView = NSHostingView(rootView: contentView)
        
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 380),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        newWindow.contentView = hostingView
        newWindow.titlebarAppearsTransparent = true
        newWindow.titleVisibility = .hidden
        newWindow.isMovableByWindowBackground = true
        newWindow.backgroundColor = .clear
        newWindow.level = .floating
        newWindow.hidesOnDeactivate = false
        
        // CRITICAL FIX: Prevent double-free crash
        newWindow.isReleasedWhenClosed = false
        
        newWindow.center()
        
        newWindow.orderFrontRegardless()
        
        self.window = newWindow
    }
    
    func closeWindow() {
        guard !isClosing else { return }
        isClosing = true
        
        if let existingWindow = window {
            print("🪟 Closing prayer window (closeWindow called)")
            existingWindow.close()
            window = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.isClosing = false
        }
    }
}
