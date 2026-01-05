import SwiftUI

struct PrayerListView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var locManager = LocalizationManager.shared
    @State private var selectedCategory: SpokenPrayer.PrayerCategory = .morning
    @State private var selectedPrayer: SpokenPrayer?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "hands.clap.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "a855f7"), Color(hex: "6366f1")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(L10n("prayer_window_title"))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                
                Spacer()
                
                Button(action: { selectedPrayer = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .opacity(selectedPrayer != nil ? 1 : 0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(nsColor: .windowBackgroundColor))
            
            Divider()
            
            if let prayer = selectedPrayer {
                // Prayer Detail View
                PrayerDetailCard(prayer: prayer, onBack: { selectedPrayer = nil })
            } else {
                // Category Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(SpokenPrayer.PrayerCategory.allCases) { category in
                            CategoryPill(
                                category: category,
                                isSelected: selectedCategory == category,
                                onTap: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                
                Divider()
                
                // Prayer List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(SpokenPrayer.forCategory(selectedCategory)) { prayer in
                            PrayerCard(prayer: prayer) {
                                withAnimation(.spring(response: 0.4)) {
                                    selectedPrayer = prayer
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .frame(width: 400, height: 500)
    }
}

struct CategoryPill: View {
    let category: SpokenPrayer.PrayerCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 12))
                Text(category.localizedName)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
            )
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

struct PrayerCard: View {
    let prayer: SpokenPrayer
    let onTap: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Text(prayer.emoji)
                    .font(.system(size: 28))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(prayer.title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text(prayer.text.components(separatedBy: "\n").first ?? "")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .shadow(color: .black.opacity(0.05), radius: isHovered ? 8 : 4, y: isHovered ? 4 : 2)
            )
            .scaleEffect(isHovered ? 1.02 : 1)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

struct PrayerDetailCard: View {
    let prayer: SpokenPrayer
    let onBack: () -> Void
    
    @State private var currentLineIndex = 0
    @State private var isAnimating = false
    @State private var showAmen = false
    @State private var contentOpacity: Double = 1
    @State private var contentScale: CGFloat = 1
    @ObservedObject var locManager = LocalizationManager.shared
    
    private var lines: [String] {
        prayer.text.components(separatedBy: "\n").filter { !$0.isEmpty }
    }
    
    private var isFinished: Bool {
        currentLineIndex >= lines.count - 1
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Back Button & Title
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 12, weight: .medium))
                            Text(L10n("prayer_back"))
                                .font(.system(size: 13, design: .rounded))
                        }
                        .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text(prayer.emoji)
                        .font(.system(size: 24))
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Prayer Title
                Text(prayer.title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                
                Divider()
                
                // Prayer Text with Animation
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                                Text(line)
                                    .font(.system(size: 17, weight: index <= currentLineIndex ? .medium : .regular, design: .serif))
                                    .foregroundStyle(index <= currentLineIndex ? Color.primary : Color.secondary.opacity(0.5))
                                    .multilineTextAlignment(.leading)
                                    .id(index)
                                    .animation(.easeInOut(duration: 0.3), value: currentLineIndex)
                            }
                            
                            Color.clear.frame(height: 50)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(24)
                    }
                    .onChange(of: currentLineIndex) { newIndex in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
                
                Divider()
                
                // Hint for Enter key
                HStack(spacing: 6) {
                    Image(systemName: "return")
                        .font(.system(size: 11, weight: .medium))
                    Text(isFinished ? L10n("prayer_enter_amen") : L10n("prayer_enter_next"))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                }
                .foregroundStyle(.secondary.opacity(0.6))
                .padding(.top, 8)
                
                // Controls
                HStack(spacing: 16) {
                    Button(action: {
                        if currentLineIndex > 0 {
                            currentLineIndex -= 1
                        }
                    }) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color(nsColor: .controlBackgroundColor)))
                    }
                    .buttonStyle(.plain)
                    .disabled(currentLineIndex == 0)
                    .opacity(currentLineIndex == 0 ? 0.3 : 1)
                    
                    Button(action: advanceOrFinish) {
                        HStack(spacing: 8) {
                            Text(isFinished ? L10n("prayer_amen") : L10n("prayer_next"))
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                            if isFinished {
                                Image(systemName: "hands.clap.fill")
                                    .font(.system(size: 12, weight: .medium))
                            } else {
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 12, weight: .medium))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: isFinished ? [Color(hex: "f093fb"), Color(hex: "f5576c")] : [Color(hex: "a855f7"), Color(hex: "6366f1")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { currentLineIndex = 0 }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color(nsColor: .controlBackgroundColor)))
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
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
            .keyboardShortcut(.defaultAction) // Triggers on Enter
        }
    }
    
    private func advanceOrFinish() {
        if currentLineIndex < lines.count - 1 {
            // Go to next line
            currentLineIndex += 1
        } else {
            // Show Amen animation
            withAnimation(.easeInOut(duration: 0.2)) {
                showAmen = true
                if AppState.shared.playPrayerSound {
                    NSSound(named: "Glass")?.play()
                }
            }
        }
    }
    
    private func closeWindow() {
        // Fade out animation
        withAnimation(.easeOut(duration: 0.4)) {
            contentOpacity = 0
            contentScale = 0.9
        }
        
        // Close after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            PrayerWindowController.shared.closeWindow()
        }
    }
}


// Prayer Window Controller
class PrayerWindowController {
    static let shared = PrayerWindowController()
    
    private var prayerWindow: NSWindow?
    private var isClosing = false
    
    func showPrayers() {
        if let existingWindow = prayerWindow {
            existingWindow.makeKeyAndOrderFront(nil)
            existingWindow.orderFrontRegardless()
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let hostingController = NSHostingController(rootView: 
            PrayerListView()
                .environmentObject(AppState.shared)
        )
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = L10n("prayer_window_title")
        window.styleMask = [.titled, .closable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.level = .floating
        window.isReleasedWhenClosed = false
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
        
        prayerWindow = window
        
        // Clean up when window closes
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            self?.prayerWindow = nil
            self?.isClosing = false
        }
    }
    
    func closeWindow() {
        guard !isClosing else { return }
        isClosing = true
        
        if let existingWindow = prayerWindow {
            existingWindow.close()
            prayerWindow = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.isClosing = false
        }
    }
}

#if DEBUG
struct PrayerListView_Previews: PreviewProvider {
    static var previews: some View {
        PrayerListView()
            .environmentObject(AppState.shared)
    }
}
#endif
