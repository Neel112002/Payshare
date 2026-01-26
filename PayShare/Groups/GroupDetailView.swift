import SwiftUI

struct GroupDetailView: View {
    let groupId: UUID
    let groupName: String

    @State private var expenses: [Expense] = []
    @State private var fairnessBalances: [FairnessBalance] = []
    @State private var fairnessScore: Int = 100
    @State private var settlements: [SplitResult] = []

    @State private var isLoading = true
    @State private var showAddExpense = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard
                fairnessCard
                settlementCard
                expensesCard
            }
            .padding()
        }
        .navigationTitle(groupName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadGroupData()
        }
        .toolbar {
            Button {
                showAddExpense = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showAddExpense) {
            // ✅ FIX: pass BOTH groupId and groupName
            AddExpenseView(
                groupId: groupId,
                groupName: groupName
            )
        }
    }

    // MARK: - API

    @MainActor
    private func loadGroupData() async {
        do {
            expenses = try await APIClient.shared.fetchGroupExpenses(groupId: groupId)

            let fairness = try await APIClient.shared.fetchGroupFairness(groupId: groupId)

            fairnessBalances = fairness.balances.map {
                FairnessBalance(name: $0.key, balance: $0.value)
            }

            fairnessScore = fairness.score

            settlements = try await APIClient.shared.fetchGroupSettlements(groupId: groupId)

            isLoading = false
        } catch {
            print("Failed to load group:", error)
            isLoading = false
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total spent")
                .foregroundStyle(.secondary)

            Text("₹\(Int(expenses.reduce(0) { $0 + $1.totalAmount }))")
                .font(.largeTitle.bold())

            Text("\(expenses.count) expenses")
                .foregroundStyle(.secondary)
        }
        .card()
    }

    // MARK: - Fairness

    private var fairnessCard: some View {
        GroupHealthCard(
            score: fairnessScore,
            members: fairnessBalances.map {
                .init(name: $0.name, delta: Int($0.balance))
            }
        )
    }

    // MARK: - Settlement

    private var settlementCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Settlements")
                .font(.headline)

            if settlements.isEmpty {
                Text("All settled 🎉")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(settlements) { s in
                    Text("\(s.from) → \(s.to): ₹\(Int(s.amount))")
                }
            }
        }
        .card()
    }

    // MARK: - Expenses

    private var expensesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Expenses")
                .font(.headline)

            if expenses.isEmpty {
                Text("No expenses yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(expenses) { expense in
                    VStack(alignment: .leading) {
                        Text(expense.title)
                            .font(.headline)

                        Text("Paid by \(expense.paidBy)")
                            .foregroundStyle(.secondary)
                    }
                    Divider()
                }
            }
        }
        .card()
    }
}
