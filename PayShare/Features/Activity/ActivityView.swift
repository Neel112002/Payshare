import SwiftUI

struct ActivityView: View {

    @EnvironmentObject private var expenseStore: ExpenseStore

    var body: some View {
        NavigationStack {
            List {
                if expenseStore.expenses.isEmpty {
                    emptyState
                } else {
                    ForEach(expenseStore.expenses) { expense in
                        activityRow(expense)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Activity")
        }
    }

    // MARK: - Row

    private func activityRow(_ expense: Expense) -> some View {
        VStack(alignment: .leading, spacing: 6) {

            HStack {
                Text(expense.title)
                    .font(.headline)

                Spacer()

                Text("₹\(Int(expense.totalAmount))")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }

            HStack {
                Text("Paid by \(expense.paidBy)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(expense.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("No activity yet")
                .font(.headline)

            Text("Add an expense to see it here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .listRowSeparator(.hidden)
    }
}
