import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {

    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?

    init() {
        checkAuthOnLaunch()
    }

    func checkAuthOnLaunch() {
        if let token = KeychainService.loadToken(),
           !token.isEmpty {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
    }

    func login(email: String, password: String) async {
        do {
            _ = try await APIClient.shared.login(email: email, password: password)
            currentUser = try await APIClient.shared.fetchMe()
            isLoggedIn = true
        } catch {
            print("❌ Login failed:", error)
            isLoggedIn = false
        }
    }

    func logout() {
        APIClient.shared.logout()
        currentUser = nil
        isLoggedIn = false
    }
}
