import SwiftUI

struct MoodSelectionView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var locManager = LocalizationManager.shared
    @State private var selectedMood: Mood?
    @State private var showContent = false
    @State private var contentOpacity: Double = 1.0
    @State private var cardAppearIndex = 0
    @State private var titleOffset: CGFloat = -30
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var lineWidth: CGFloat = 0
    
    // Time-based greeting
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return L10n("greeting_morning")
        case 12..<17: return L10n("greeting_afternoon")
        case 17..<21: return L10n("greeting_evening")
        default: return L10n("greeting_night")
        }
    }
    
    var body: some View {
        ZStack {
            // Dark gradient background
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
            
            // Subtle glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "6366f1").opacity(0.08), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 500, height: 500)
                .blur(radius: 60)
                .offset(y: -100)
            
            VStack(spacing: 36) {
                Spacer()
                    .frame(height: 20)
                
                // Header - minimal
                VStack(spacing: 16) {
                    // SF Symbol icon
                    Image(systemName: "hands.clap.fill")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "a855f7"), Color(hex: "6366f1")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(iconScale)
                        .opacity(iconOpacity)
                    
                    Text(greeting)
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .offset(y: titleOffset)
                    
                    Text(L10n("mood_selection_title"))
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                        .offset(y: titleOffset)
                    
                    // Animated line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "a855f7"), Color(hex: "6366f1")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: lineWidth, height: 2)
                        .animation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.4), value: lineWidth)
                }
                .opacity(showContent ? 1 : 0)
                
                // Mood grid - minimal cards
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(Array(Mood.allCases.enumerated()), id: \.element) { index, mood in
                        MinimalMoodCard(
                            mood: mood,
                            isSelected: selectedMood == mood,
                            onTap: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    selectedMood = mood
                                }
                                // Auto-confirm
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    confirmSelection()
                                }
                            }
                        )
                        .opacity(index < cardAppearIndex ? 1 : 0)
                        .offset(y: index < cardAppearIndex ? 0 : 30)
                        .scaleEffect(index < cardAppearIndex ? 1 : 0.9)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 40)
            }
            .padding(.vertical, 50)
            .padding(.horizontal, 24)
            .opacity(contentOpacity)
        }
        .frame(width: 500, height: 700)
        .onAppear {
            startEntranceAnimation()
            
            // Make window float above ALL others (including Chrome, Settings, etc.)
            DispatchQueue.main.async {
                // Find any window that might contain this view
                for window in NSApp.windows {
                    if window.identifier?.rawValue.contains("mood-selection") == true ||
                       window.title.contains("Stimmung") ||
                       (window.contentViewController != nil && window.styleMask.contains(.borderless)) {
                        window.level = .screenSaver  // Highest z-index
                        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                        window.orderFrontRegardless()
                        NSApp.activate(ignoringOtherApps: true)
                        break
                    }
                }
            }
        }
    }
    
    private func startEntranceAnimation() {
        // Icon entrance
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }
        
        // Title entrance
        withAnimation(.easeOut(duration: 0.6).delay(0.15)) {
            titleOffset = 0
            showContent = true
        }
        
        // Line expand
        lineWidth = 80
        
        // Cards stagger
        for i in 0...Mood.allCases.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.08) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    cardAppearIndex = i + 1
                }
            }
        }
    }
    
    private func confirmSelection() {
        guard let mood = selectedMood else { return }
        
        // Slow fade out
        withAnimation(.easeOut(duration: 1.0)) {
            contentOpacity = 0
            iconScale = 1.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            appState.setMood(mood)
            dismiss()
            
            if let window = NSApp.windows.first(where: { $0.identifier?.rawValue.contains("mood-selection") == true }) {
                window.close()
            }
        }
    }
}

// Minimal mood card with icons
struct MinimalMoodCard: View {
    let mood: Mood
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isHovered = false
    
    // Map moods to SF Symbols
    private var moodIcon: String {
        switch mood {
        case .joyful: return "sun.max.fill"
        case .sad: return "cloud.rain.fill"
        case .anxious: return "wind"
        case .thoughtful: return "sparkles"
        case .spiritual: return "hands.clap.fill"
        case .hopeful: return "star.fill"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 14) {
                // Icon instead of emoji
                Image(systemName: moodIcon)
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(
                        isSelected ?
                            AnyShapeStyle(LinearGradient(colors: mood.gradient, startPoint: .top, endPoint: .bottom)) :
                            AnyShapeStyle(Color.white.opacity(0.7))
                    )
                    .scaleEffect(isSelected ? 1.15 : (isHovered ? 1.05 : 1.0))
                
                Text(mood.title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: mood.gradient.map { $0.opacity(0.3) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.03))
                    }
                    
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ?
                                LinearGradient(colors: mood.gradient, startPoint: .topLeading, endPoint: .bottomTrailing) :
                                LinearGradient(colors: [Color.white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: isSelected ? 1.5 : 1
                        )
                }
            )
            .shadow(
                color: isSelected ? mood.accentColor.opacity(0.25) : .clear,
                radius: isSelected ? 20 : 0,
                y: isSelected ? 8 : 0
            )
            .scaleEffect(isHovered && !isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

// Keep AnimatedGradientBackground for compatibility but not used
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
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
    }
}

#if DEBUG
struct MoodSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        MoodSelectionView()
            .environmentObject(AppState.shared)
    }
}
#endif
