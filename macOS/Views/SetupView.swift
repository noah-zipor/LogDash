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

            // Subtle background glow
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.cyan.opacity(0.15)]), startPoint: .top, endPoint: .bottom))
                .frame(width: 500, height: 500)
                .blur(radius: 120)

            VStack(spacing: 24) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(colors: [.white.opacity(0.9), .blue.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .blue.opacity(0.4), radius: 12, x: 0, y: 0)

                VStack(spacing: 6) {
                    Text("Initialize Dashboard")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Set a secure password to protect your workspace.")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 16) {
                    LabeledTextField(title: "Your Name", text: $viewModel.userName, placeholder: "Enter your name")
                    LabeledPasswordField(title: "New Password", text: $viewModel.password)
                    LabeledPasswordField(title: "Confirm Password", text: $viewModel.confirmPassword)
                }

                if viewModel.isErrorVisible {
                    Label(viewModel.errorMessage, systemImage: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Button(action: { withAnimation { viewModel.setup() } }) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Complete Setup")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.blue)
                .frame(width: 300)

                Button("Exit") { viewModel.exit() }
                    .buttonStyle(.plain)
                    .foregroundColor(.white.opacity(0.4))
                    .font(.footnote)
            }
            .padding(50)
            .frame(width: 420)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.black.opacity(0.4))
                    .background(VisualEffectView(material: .popover, blendingMode: .withinWindow).cornerRadius(30))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(LinearGradient(colors: [.white.opacity(0.25), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.5), radius: 40, x: 0, y: 20)
            .drawingGroup()
            .scaleEffect(isLoaded ? 1 : 0.9)
            .opacity(isLoaded ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isLoaded)
            .onAppear { isLoaded = true }
        }
    }
}

private struct LabeledTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String

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
        }
        .frame(width: 300)
    }
}

private struct LabeledPasswordField: View {
    let title: String
    @Binding var text: String

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
        }
        .frame(width: 300)
    }
}
