import Foundation
import Combine

class WelcomeViewModel: ObservableObject {
    @Published var greeting = ""
    var onNavigationRequested: (() -> Void)?

    init() {
        greeting = buildGreeting()
        startWelcomeSequence()
    }

    private func buildGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning."
        case 12..<17: return "Good afternoon."
        case 17..<21: return "Good evening."
        default:      return "Good night."
        }
    }

    private func startWelcomeSequence() {
        // 1.5 s hold — fast enough to feel snappy
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.onNavigationRequested?()
        }
    }
}
