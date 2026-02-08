import Foundation
import Combine

@MainActor
final class ActivityStore: ObservableObject {

    @Published var activities: [Expense] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func loadActivity() async {
        isLoading = true
        errorMessage = nil

        do {
            // 🔥 Reuse existing backend call
            let groups = try await APIClient.shared.fetchGroups()

            var allExpenses: [Expense] = []

            for group in groups {
                let expenses = try await APIClient.shared.fetchGroupExpenses(groupId: group.id)
                allExpenses.append(contentsOf: expenses)
            }

            // Newest first
            self.activities = allExpenses.sorted {
                $0.createdAt > $1.createdAt
            }

        } catch {
            errorMessage = "Failed to load activity"
            print("❌ Activity load error:", error)
        }

        isLoading = false
    }
}
