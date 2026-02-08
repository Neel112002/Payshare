import Foundation

@MainActor
final class ProfileStore: ObservableObject {

    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            user = try await APIClient.shared.fetchMe()
        } catch {
            errorMessage = "Failed to load profile"
            print("❌ Profile load error:", error)
        }

        isLoading = false
    }
}
