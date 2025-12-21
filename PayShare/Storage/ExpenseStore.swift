import SwiftUI
import Combine

@MainActor
final class ExpenseStore: ObservableObject {

    @Published private(set) var expenses: [Expense] = []

    func add(_ expense: Expense) {
        expenses.insert(expense, at: 0)
    }
}
