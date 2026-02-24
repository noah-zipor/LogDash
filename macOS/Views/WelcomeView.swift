import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: WelcomeViewModel
    @State private var offset: CGFloat = 60
    @State private var opacity: Double = 0
    @State private var glowRadius: CGFloat = 0

    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                .ignoresSafeArea()

            Color.black.opacity(0.35).ignoresSafeArea()
                .filmGrain()

            // Subtle ambient glow behind text
            Ellipse()
                .fill(Color.white.opacity(0.06))
                .frame(width: 700, height: 200)
                .blur(radius: glowRadius)

            VStack(spacing: 30) {
                LogoView(size: 120)
                    .shadow(color: .white.opacity(0.2), radius: 20, x: 0, y: 0)
                    .offset(y: offset)
                    .opacity(opacity)

                Text(viewModel.greeting)
                    .font(.system(size: 130, weight: .light, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.55)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    .offset(y: offset)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.cubicEaseOut(duration: 1.1)) {
                offset = 0
                opacity = 1
            }
            withAnimation(.easeOut(duration: 1.5)) {
                glowRadius = 80
            }
        }
    }
}
