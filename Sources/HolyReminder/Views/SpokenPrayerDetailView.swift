import SwiftUI

// View for displaying a single spoken prayer (similar to VerseDetailView)
struct SpokenPrayerDetailView: View {
    let prayer: SpokenPrayer
    let mood: Mood
    
    @State private var currentLineIndex = 0
    @State private var showAmen = false
    @State private var contentScale: CGFloat = 0.95
    @State private var contentOpacity: Double = 0
    @State private var lineOffset: CGFloat = 50
    @State private var isClosing = false
    @ObservedObject var locManager = LocalizationManager.shared
    
    private var lines: [String] {
        prayer.text.components(separatedBy: "\n").filter { !$0.isEmpty }
    }
    
    private var isFinished: Bool {
        currentLineIndex >= lines.count - 1
    }
    
    var body: some View {
        ZStack {
            // Gradient background
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
            VStack(spacing: 20) {
                Spacer()
                
                // Prayer icon with emoji
                Text(prayer.emoji)
                    .font(.system(size: 50))
                    .scaleEffect(contentScale)
                
                // Title with underline animation
                VStack(spacing: 8) {
                    Text(prayer.title)
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
                
                // Prayer text with line highlighting
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .center, spacing: 12) {
                            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                                Text(line)
                                    .font(.system(size: 16, weight: index <= currentLineIndex ? .medium : .regular, design: .serif))
                                    .foregroundStyle(index <= currentLineIndex ? Color.white : Color.white.opacity(0.4))
                                    .multilineTextAlignment(.center)
                                    .id(index) // Important for scrolling
                                    .animation(.easeInOut(duration: 0.3), value: currentLineIndex)
                                    .frame(maxWidth: .infinity)
                            }
                            
                            // Spacer at bottom to allow scrolling last line up
                            Color.clear.frame(height: 100)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                    }
                    .onChange(of: currentLineIndex) { newIndex in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
                
                Spacer()
                
                // Progress indicator
                HStack(spacing: 4) {
                    ForEach(0..<lines.count, id: \.self) { index in
                        Circle()
                            .fill(index <= currentLineIndex ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.bottom, 8)
                
                // Hint
                HStack(spacing: 6) {
                    Image(systemName: "return")
                        .font(.system(size: 12, weight: .medium))
                    Text(isFinished ? L10n("prayer_enter_amen") : L10n("prayer_enter_next"))
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
                
                // Close button
                Button(action: closeWindow) {
                    Text(L10n("close"))
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
            
            // Invisible button for Enter key
            Button(action: advanceOrFinish) {
                EmptyView()
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.defaultAction)
        }
        .frame(width: 500, height: 500)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                contentScale = 1.0
                contentOpacity = 1.0
            }
            lineOffset = 120
        }
    }
    
    private func advanceOrFinish() {
        if currentLineIndex < lines.count - 1 {
            currentLineIndex += 1
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                showAmen = true
                if AppState.shared.playPrayerSound {
                    NSSound(named: "Glass")?.play()
                }
            }
        }
    }
    
    private func closeWindow() {
        guard !isClosing else { return }
        isClosing = true
        
        withAnimation(.easeOut(duration: 0.4)) {
            contentOpacity = 0
            contentScale = 0.9
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            SpokenPrayerWindowController.shared.closeWindow()
        }
    }
}

// Window controller for showing spoken prayer detail
class SpokenPrayerWindowController {
    static let shared = SpokenPrayerWindowController()
    private var window: NSWindow?
    private var isClosing = false
    
    func showPrayer(_ prayer: SpokenPrayer, mood: Mood) {
        if isClosing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.showPrayer(prayer, mood: mood)
            }
            return
        }
        
        if let existingWindow = window {
            existingWindow.close()
            window = nil
        }
        
        let contentView = SpokenPrayerDetailView(prayer: prayer, mood: mood)
        let hostingView = NSHostingView(rootView: contentView)
        
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 500),
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
        newWindow.isReleasedWhenClosed = false
        newWindow.center()
        newWindow.orderFrontRegardless()
        
        self.window = newWindow
    }
    
    func closeWindow() {
        guard !isClosing else { return }
        isClosing = true
        
        if let existingWindow = window {
            existingWindow.close()
            window = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.isClosing = false
        }
    }
}
