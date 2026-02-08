import Foundation
import Combine

@MainActor
final class AuthStore: ObservableObject {

    @Published var token: String? = nil

    var isLoggedIn: Bool {
        token != nil
    }

    func setToken(_ token: String) {
        self.token = token
    }

    func logout() {
        token = nil
    }
}
