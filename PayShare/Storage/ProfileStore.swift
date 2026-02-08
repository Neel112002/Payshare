import Foundation
import Combine

@MainActor
final class ProfileStore: ObservableObject {

    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await APIClient.shared.fetchMe()
            self.user = user
        } catch {
            print("❌ Profile load error:", error)
            errorMessage = "Failed to load profile"
        }

        isLoading = false
    }

    func logout() {
        user = nil
        APIClient.shared.authToken = nil
    }
}
