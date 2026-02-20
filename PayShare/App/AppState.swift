import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {

    @Published var isLoggedIn: Bool

    init() {
        // Auto login if token exists
        self.isLoggedIn = KeychainService.loadToken() != nil
    }

    func logout() {
        APIClient.shared.logout()
        isLoggedIn = false
    }
}
