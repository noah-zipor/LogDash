import XCTest
@testable import StartupDashboard

final class StartupDashboardTests: XCTestCase {
    func testWelcomeViewModelNavigation() {
        let expectation = self.expectation(description: "Navigation requested after delay")
        let vm = WelcomeViewModel()
        vm.onNavigationRequested = {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testLoginViewModelFailure() {
        let mockAuth = MockAuthService(shouldSucceed: false)
        let vm = LoginViewModel(authService: mockAuth)
        vm.password = "wrong"
        vm.login()

        XCTAssertTrue(vm.isErrorVisible)
        XCTAssertEqual(vm.errorMessage, "Incorrect Password")
    }
}

class MockAuthService: AuthServiceProtocol {
    var shouldSucceed: Bool
    init(shouldSucceed: Bool) { self.shouldSucceed = shouldSucceed }
    func authenticate(password: String) -> Bool { return shouldSucceed }
    func setPassword(newPassword: String) {}
    func isPasswordSet() -> Bool { return true }
}
