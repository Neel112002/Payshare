import SwiftUI

struct GroupDetailView: View {
    let groupName: String

    @EnvironmentObject private var expenseStore: ExpenseStore
    @State private var showAddExpense = false

    // MARK: - Derived Data

    private var groupExpenses: [Expense] {
        expenseStore.expenses.filter { $0.groupName == groupName }
    }

    private var totalSpent: Double {
        groupExpenses.reduce(0) { $0 + $1.totalAmount }
    }

    private var fairnessBalances: [FairnessBalance] {
        FairnessCalculator.calculate(expenses: groupExpenses)
    }

    // MARK: - View

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Header
                headerCard

                // Fairness / Health
                fairnessCard

                // Settlement
                settlementCard

                // Expenses
                expensesCard
            }
            .padding(16)
        }
        .navigationTitle(groupName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView(groupName: groupName)
                .environmentObject(expenseStore)
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total spent")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("₹\(Int(totalSpent))")
                .font(.largeTitle.bold())

            Text("\(groupExpenses.count) expenses")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Fairness Card (REAL LOGIC)

    private var fairnessCard: some View {
        GroupHealthCard(
            score: fairnessScore,
            members: fairnessBalances.map {
                .init(
                    name: $0.name,
                    delta: Int($0.balance)
                )
            }
        )
    }

    private var fairnessScore: Int {
        let totalImbalance = fairnessBalances
            .map { abs($0.balance) }
            .reduce(0, +)

        if totalImbalance == 0 { return 100 }

        return max(0, 100 - Int(totalImbalance))
    }

    // MARK: - Settlement Card (REAL LOGIC)

    private var settlementCard: some View {
        let debtors = fairnessBalances.filter { $0.balance < 0 }
        let creditors = fairnessBalances.filter { $0.balance > 0 }

        guard
            let debtor = debtors.first,
            let creditor = creditors.first
        else {
            return AnyView(EmptyView())
        }

        return AnyView(
            VStack(alignment: .leading, spacing: 8) {
                Text("Suggested settlement")
                    .font(.headline)

                Text(
                    "\(debtor.name) owes \(creditor.name) ₹\(Int(abs(debtor.balance)))"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        )
    }

    // MARK: - Expenses Card

    private var expensesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Expenses")
                .font(.headline)

            if groupExpenses.isEmpty {
                emptyState
            } else {
                ForEach(groupExpenses) { expense in
                    expenseRow(expense)

                    if expense.id != groupExpenses.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Expense Row

    private func expenseRow(_ expense: Expense) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.headline)

                Text("Paid by \(expense.paidBy)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("₹\(Int(expense.totalAmount))")
                    .font(.headline)

                Text(expense.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)

            Text("No expenses yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}
