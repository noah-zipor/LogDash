import Foundation
import Combine

class WelcomeViewModel: ObservableObject {
    @Published var greeting = "Hello!"
    var onNavigationRequested: (() -> Void)?

    init() {
        startWelcomeSequence()
    }

    private func startWelcomeSequence() {
        // Reduced hold time for a faster feel
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.onNavigationRequested?()
        }
    }
}
