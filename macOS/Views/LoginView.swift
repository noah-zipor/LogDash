import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var shakeOffset: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.5
    @State private var isLoaded = false

    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                .ignoresSafeArea()

            Color.black.opacity(0.4).ignoresSafeArea()
                .filmGrain()

            // Animated background glow
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 450, height: 450)
                .blur(radius: 110)
                .opacity(glowOpacity)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: glowOpacity)
                .onAppear { glowOpacity = 0.8 }

            VStack(spacing: 28) {
                // Profile Icon with pulse
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(
                        LinearGradient(colors: [.white, .blue.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .blue.opacity(0.4), radius: 12, x: 0, y: 0)
                    .scaleEffect(pulseScale)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulseScale)
                    .onAppear { pulseScale = 1.05 }

                VStack(spacing: 4) {
                    Text("Welcome Back")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.white, .white.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                        )
                        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 5)
                    Text("Enter your password to continue")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.white.opacity(0.45))
                }

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 290)
                    .onSubmit { withAnimation { viewModel.login() } }

                // Error / attempts remaining
                VStack(spacing: 4) {
                    if viewModel.isErrorVisible {
                        Label(viewModel.errorMessage, systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.caption.weight(.semibold))
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    // Show attempts remaining warning when < 3 left
                    if viewModel.attemptsRemaining < 3 && viewModel.attemptsRemaining > 0 {
                        Text("\(viewModel.attemptsRemaining) attempt\(viewModel.attemptsRemaining == 1 ? "" : "s") remaining before lockout")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.isErrorVisible)

                Button(action: { withAnimation { viewModel.login() } }) {
                    HStack {
                        Image(systemName: "lock.open.fill")
                        Text("Unlock")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.blue)
                .frame(width: 290)

                Button("Exit Application") {
                    withAnimation { viewModel.exit() }
                }
                .buttonStyle(.plain)
                .foregroundColor(.white.opacity(0.4))
                .font(.footnote)
            }
            .padding(50)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.black.opacity(0.4))
                    .background(VisualEffectView(material: .popover, blendingMode: .withinWindow).cornerRadius(30))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(
                                LinearGradient(colors: [.white.opacity(0.3), .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: .black.opacity(0.5), radius: 40, x: 0, y: 20)
            .drawingGroup()
            .offset(x: shakeOffset)
            .scaleEffect(isLoaded ? 1 : 0.92)
            .opacity(isLoaded ? 1 : 0)
            .animation(.spring(response: 0.55, dampingFraction: 0.8), value: isLoaded)
            .onAppear { isLoaded = true }
            .onChange(of: viewModel.isErrorVisible) { newValue in
                if newValue {
                    withAnimation(.default.repeatCount(4, autoreverses: true).speed(5)) {
                        shakeOffset = 10
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        shakeOffset = 0
                    }
                }
            }
        }
    }
}
