import Foundation
import SwiftUI
import Combine

@MainActor
final class ProfileStore: ObservableObject {

    @Published var user: User?
    @Published var isLoading = false

    // MARK: - Load Profile (/me)

    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let fetchedUser = try await APIClient.shared.fetchMe()
            self.user = fetchedUser
        } catch {
            print("❌ Failed to load profile:", error)
            self.user = nil
        }
    }

    // MARK: - Logout

    func logout() {
        APIClient.shared.logout()
        user = nil
    }
}
