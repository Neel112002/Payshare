import Foundation
import Combine

final class ProfileStore: ObservableObject {

    @Published var user: UserProfile
    @Published var isLoggedIn: Bool = true

    init() {
        self.user = UserProfile(
            name: "Neel Shah",
            email: "neel@example.com"
        )
    }

    func logout() {
        isLoggedIn = false
        print("User logged out")
    }
}
