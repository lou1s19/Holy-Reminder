import SwiftUI

struct AmenOverlayView: View {
    @Binding var isShowing: Bool
    var onComplete: (() -> Void)? = nil
    
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Subtle dark overlay with blur
            Color.black.opacity(0.4 * opacity)
                .ignoresSafeArea()
            
            // Expanding ring animation
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: "f093fb").opacity(0.6),
                            Color(hex: "f5576c").opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 200, height: 200)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)
            
            // Second ring (delayed)
            Circle()
                .stroke(
                    Color.white.opacity(0.2),
                    lineWidth: 2
                )
                .frame(width: 150, height: 150)
                .scaleEffect(ringScale * 0.8)
                .opacity(ringOpacity * 0.5)
            
            // Main content
            VStack(spacing: 20) {
                // Minimal icon - just hands
                Image(systemName: "hands.clap.fill")
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(scale)
                
                Text("Amen")
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .offset(y: textOffset)
            }
            .opacity(opacity)
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Smooth entrance
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            scale = 1.0
            opacity = 1.0
            textOffset = 0
        }
        
        // Ring expansion
        withAnimation(.easeOut(duration: 1.2)) {
            ringScale = 2.5
            ringOpacity = 1.0
        }
        
        // Fade out ring
        withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
            ringOpacity = 0
        }
        
        // Exit animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 0
                scale = 1.1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isShowing = false
                onComplete?()
            }
        }
    }
}

// Window for showing Amen overlay
class AmenWindowController {
    static let shared = AmenWindowController()
    private var window: NSWindow?
    
    func showAmen(onComplete: (() -> Void)? = nil) {
        guard window == nil else { return }
        
        let contentView = AmenContentView(onComplete: onComplete) { [weak self] in
            self?.closeWindow()
        }
        
        let hostingView = NSHostingView(rootView: contentView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window.contentView = hostingView
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.center()
        window.makeKeyAndOrderFront(nil)
        
        self.window = window
    }
    
    private func closeWindow() {
        window?.close()
        window = nil
    }
}

struct AmenContentView: View {
    var onComplete: (() -> Void)?
    let onDismiss: () -> Void
    @State private var isShowing = true
    
    var body: some View {
        ZStack {
            if isShowing {
                AmenOverlayView(isShowing: $isShowing, onComplete: onComplete)
            }
        }
        .frame(width: 400, height: 300)
        .background(Color.clear)
        .onChange(of: isShowing) { newValue in
            if !newValue {
                onDismiss()
            }
        }
    }
}
