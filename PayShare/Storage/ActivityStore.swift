import Foundation
import SwiftUI
import Combine

@MainActor
final class ActivityStore: ObservableObject {

    @Published var items: [ActivityItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Public API

    func loadActivity() async {
        isLoading = true
        errorMessage = nil

        do {
            let groups = try await APIClient.shared.fetchGroups()
            var allItems: [ActivityItem] = []

            for group in groups {
                let expenses = try await APIClient.shared.fetchGroupExpenses(groupId: group.id)

                let mapped: [ActivityItem] = expenses.map { expense in
                    ActivityItem(
                        id: expense.id,
                        groupId: group.id,
                        groupName: group.name,
                        title: expense.title,
                        amount: expense.totalAmount,
                        paidBy: expense.paidBy,
                        createdAt: expense.createdAt
                    )
                }

                allItems.append(contentsOf: mapped)
            }

            // Sort newest first
            items = allItems.sorted {
                $0.createdAt > $1.createdAt
            }

        } catch {
            errorMessage = "Failed to load activity"
            print("❌ Activity load error:", error)
        }

        isLoading = false
    }
}

