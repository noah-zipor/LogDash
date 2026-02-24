import SwiftUI

struct SetupView: View {
    @ObservedObject var viewModel: SetupViewModel
    @State private var isLoaded = false

    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                .ignoresSafeArea()

            Color.black.opacity(0.4).ignoresSafeArea()
                .filmGrain()

            // Ambient background glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.1), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 500, height: 500)
                .blur(radius: 80)
                .opacity(0.6)

            VStack(spacing: 32) {
                LogoView(size: 80)
                    .shadow(color: .blue.opacity(0.2), radius: 15, x: 0, y: 0)

                VStack(spacing: 8) {
                    Text("Initialize Dashboard")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Set a secure password to protect your workspace")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 18) {
                    LabeledTextField(title: "Your Name", text: $viewModel.userName, placeholder: "Enter your name", onSubmit: { viewModel.setup() })
                    LabeledPasswordField(title: "New Password", text: $viewModel.password, onSubmit: { viewModel.setup() })
                    LabeledPasswordField(title: "Confirm Password", text: $viewModel.confirmPassword, onSubmit: { viewModel.setup() })
                }

                if viewModel.isErrorVisible {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                        Text(viewModel.errorMessage)
                            .font(.system(.caption, design: .rounded).weight(.medium))
                    }
                    .foregroundColor(.red.opacity(0.9))
                    .padding(.top, -8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Button(action: { withAnimation { viewModel.setup() } }) {
                    HStack(spacing: 8) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Complete Setup")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.85), Color.blue.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
                }
                .buttonStyle(.plain)
                .frame(width: 300)

                Button("Exit Application") { 
                    withAnimation { viewModel.exit() } 
                }
                .buttonStyle(.plain)
                .foregroundColor(.white.opacity(0.3))
                .font(.system(.footnote, design: .rounded))
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 50)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.black.opacity(0.35))
                    .background(VisualEffectView(material: .popover, blendingMode: .withinWindow).cornerRadius(32))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(LinearGradient(colors: [.white.opacity(0.2), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.5), radius: 60, x: 0, y: 30)
            .frame(width: 400)
            .scaleEffect(isLoaded ? 1 : 0.94)
            .opacity(isLoaded ? 1 : 0)
            .animation(.spring(response: 0.55, dampingFraction: 0.8), value: isLoaded)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isLoaded = true
                }
            }

        }
    }
}

private struct LabeledTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var onSubmit: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundColor(.white.opacity(0.5))
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                        )
                )
                .onSubmit { onSubmit?() }
        }
        .frame(width: 300)
    }
}

private struct LabeledPasswordField: View {
    let title: String
    @Binding var text: String
    var onSubmit: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundColor(.white.opacity(0.5))
            
            SecureField("••••••••", text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                        )
                )
                .onSubmit { onSubmit?() }
        }
        .frame(width: 300)
    }
}
