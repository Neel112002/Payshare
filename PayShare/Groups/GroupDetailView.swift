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
            VStack(spacing: 20) {

                headerCard
                fairnessCard
                settlementCard
                expensesCard
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(groupName)
        .navigationBarTitleDisplayMode(.inline)

        // Initial load
        .task {
            await loadGroupData()
        }

        // Add expense button
        .toolbar {
            Button {
                showAddExpense = true
            } label: {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
            }
        }

        // ✅ CRITICAL FIX: reload after sheet closes
        .sheet(isPresented: $showAddExpense, onDismiss: {
            Task {
                await loadGroupData()
            }
        }) {
            AddExpenseView(
                groupId: groupId,
                groupName: groupName
            )
        }
    }

    // MARK: - API

    @MainActor
    private func loadGroupData() async {
        isLoading = true
        do {
            expenses = try await APIClient.shared.fetchGroupExpenses(groupId: groupId)

            let fairness = try await APIClient.shared.fetchGroupFairness(groupId: groupId)
            fairnessBalances = fairness.balances.map {
                FairnessBalance(name: $0.key, balance: $0.value)
            }
            fairnessScore = fairness.score

            settlements = try await APIClient.shared.fetchGroupSettlements(groupId: groupId)
        } catch {
            print("❌ Failed to load group:", error)
        }
        isLoading = false
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(spacing: 10) {
            Text("Total Spent")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("₹\(Int(expenses.reduce(0) { $0 + $1.totalAmount }))")
                .font(.largeTitle.bold())

            Text("\(expenses.count) expenses")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
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

    // MARK: - Settlements

    private var settlementCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settlements")
                .font(.headline)

            if settlements.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)

                    Text("All settled")
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(settlements) { s in
                    HStack {
                        Text("\(s.from) → \(s.to)")
                        Spacer()
                        Text("₹\(Int(s.amount))")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                }
            }
        }
        .card()
    }

    // MARK: - Expenses

    private var expensesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Expenses")
                .font(.headline)

            if expenses.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "receipt")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)

                    Text("No expenses yet")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(expenses) { expense in
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(expense.title)
                                    .font(.headline)

                                Text("Paid by \(expense.paidBy)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("₹\(Int(expense.totalAmount))")
                                .fontWeight(.semibold)
                        }
                        Divider()
                    }
                }
            }
        }
        .card()
    }
}
