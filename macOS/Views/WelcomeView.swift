import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: WelcomeViewModel
    @State private var offset: CGFloat = 100
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                .ignoresSafeArea()

            Color.black.opacity(0.4).ignoresSafeArea()
                .filmGrain()

            Text(viewModel.greeting)
                .font(.system(size: 140, weight: .light))
                .foregroundColor(.white)
                .offset(y: offset)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.cubicEaseOut(duration: 1.2)) {
                        offset = 0
                        opacity = 1
                    }
                }
        }
    }
}
