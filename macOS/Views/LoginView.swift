import SwiftUI
import AppKit

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var shakeOffset: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.4
    @State private var isLoaded = false
    @FocusState private var isPasswordFocused: Bool

    private let username: String = NSFullUserName()

    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                .ignoresSafeArea()

            Color.black.opacity(0.45).ignoresSafeArea()
                .filmGrain()

            // Ambient background glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.blue.opacity(0.35), Color.purple.opacity(0.2), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 260
                    )
                )
                .frame(width: 520, height: 520)
                .blur(radius: 60)
                .opacity(glowOpacity)
                .animation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: glowOpacity)
                .onAppear { glowOpacity = 0.75 }

            VStack(spacing: 32) {

                // ── Avatar + Name ──────────────────────────────────────────
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.15), Color.blue.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 106, height: 106)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.35), .white.opacity(0.05)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )

                        if let logoUrl = Bundle.module.url(forResource: "icon", withExtension: "png"),
                           let logoImage = NSImage(contentsOf: logoUrl) {
                            Image(nsImage: logoImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, height: 70)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 40, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .white.opacity(0.6)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                    }
                    .scaleEffect(pulseScale)
                    .shadow(color: .blue.opacity(0.2), radius: 25, x: 0, y: 0)
                    .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: pulseScale)
                    .onAppear { pulseScale = 1.04 }

                    VStack(spacing: 3) {
                        Text(username)
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Enter your password to continue")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }

                // ── Password Field ─────────────────────────────────────────
                VStack(spacing: 10) {
                    GlassPasswordField(
                        placeholder: "Password",
                        text: $viewModel.password,
                        isFocused: $isPasswordFocused,
                        onSubmit: { withAnimation { viewModel.login() } }
                    )

                    // Error / lockout feedback
                    if viewModel.isErrorVisible {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption2)
                            Text(viewModel.errorMessage)
                                .font(.system(.caption, design: .rounded).weight(.medium))
                        }
                        .foregroundColor(.red.opacity(0.9))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .padding(.horizontal, 4)
                    }

                    if !viewModel.isErrorVisible && viewModel.attemptsRemaining < 3 && viewModel.attemptsRemaining > 0 {
                        Text("\(viewModel.attemptsRemaining) attempt\(viewModel.attemptsRemaining == 1 ? "" : "s") remaining before lockout")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.orange.opacity(0.85))
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.isErrorVisible)

                // ── Unlock Button ──────────────────────────────────────────
                Button(action: { withAnimation { viewModel.login() } }) {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Unlock")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.55)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .blue.opacity(0.4), radius: 12, x: 0, y: 6)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
                }
                .buttonStyle(.plain)
                .frame(width: 290)

                Button("Exit Application") {
                    withAnimation { viewModel.exit() }
                }
                .buttonStyle(.plain)
                .foregroundColor(.white.opacity(0.3))
                .font(.system(.footnote, design: .rounded))
            }
            .padding(.horizontal, 50)
            .padding(.vertical, 50)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.black.opacity(0.35))
                    .background(
                        VisualEffectView(material: .popover, blendingMode: .withinWindow)
                            .cornerRadius(30)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.25), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: .black.opacity(0.55), radius: 50, x: 0, y: 24)
            .frame(width: 390)
            .offset(x: shakeOffset)
            .scaleEffect(isLoaded ? 1 : 0.92)
            .opacity(isLoaded ? 1 : 0)
            .animation(.spring(response: 0.55, dampingFraction: 0.82), value: isLoaded)
            .onAppear {
                isLoaded = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isPasswordFocused = true
                }
            }
            .onChange(of: viewModel.isErrorVisible) { newValue in
                if newValue {
                    withAnimation(.default.repeatCount(4, autoreverses: true).speed(5)) {
                        shakeOffset = 10
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        shakeOffset = 0
                        isPasswordFocused = true
                    }
                }
            }
        }
    }
}

// MARK: - Custom Glass Password Field

private struct GlassPasswordField: View {
    let placeholder: String
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let onSubmit: () -> Void

    @State private var isRevealed = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.fill")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.35))
                .frame(width: 18)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.white.opacity(0.25))
                }
                if isRevealed {
                    TextField("", text: $text)
                        .textFieldStyle(.plain)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.white)
                        .focused(isFocused)
                        .onSubmit(onSubmit)
                } else {
                    SecureField("", text: $text)
                        .textFieldStyle(.plain)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.white)
                        .focused(isFocused)
                        .onSubmit(onSubmit)
                }
            }

            Button(action: { isRevealed.toggle() }) {
                Image(systemName: isRevealed ? "eye.slash" : "eye")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.3))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .frame(width: 290)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(isFocused.wrappedValue ? 0.1 : 0.06))
                .animation(.easeOut(duration: 0.15), value: isFocused.wrappedValue)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isFocused.wrappedValue
                        ? Color.blue.opacity(0.7)
                        : Color.white.opacity(0.12),
                    lineWidth: isFocused.wrappedValue ? 1.5 : 0.5
                )
                .animation(.easeOut(duration: 0.15), value: isFocused.wrappedValue)
        )
    }
}
