import SwiftUI

struct SetupView: View {
    @ObservedObject var viewModel: SetupViewModel

    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                .ignoresSafeArea()

            Color.black.opacity(0.4).ignoresSafeArea()
                .filmGrain()

            VStack(spacing: 20) {
                Text("Initialize Dashboard")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text("Set a secure password for your first run.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)

                VStack(alignment: .leading, spacing: 5) {
                    Text("New Password")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    SecureField("", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .frame(width: 280)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Confirm Password")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    SecureField("", text: $viewModel.confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .frame(width: 280)

                if viewModel.isErrorVisible {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button("Complete Setup") {
                    viewModel.setup()
                }
                .buttonStyle(.borderedProminent)
                .frame(width: 280)
                .padding(.top, 10)

                Button("Exit") {
                    viewModel.exit()
                }
                .buttonStyle(.plain)
                .foregroundColor(.white.opacity(0.5))
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 15)
        }
    }
}
