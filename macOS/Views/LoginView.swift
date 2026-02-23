import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var shakeOffset: CGFloat = 0

    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                .ignoresSafeArea()

            Color.black.opacity(0.4).ignoresSafeArea()
                .filmGrain()

            VStack(spacing: 30) {
                Text("Authentication")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 250)

                if viewModel.isErrorVisible {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button("Unlock") {
                    viewModel.login()
                }
                .buttonStyle(.borderedProminent)
                .frame(width: 250)

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
            .offset(x: shakeOffset)
            .onChange(of: viewModel.isErrorVisible) { newValue in
                if newValue {
                    withAnimation(.default.repeatCount(3, autoreverses: true).speed(4)) {
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
