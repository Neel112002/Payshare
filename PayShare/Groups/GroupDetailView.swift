import SwiftUI

struct GroupDetailView: View {
    let groupName: String

    @State private var showAddExpense = false
    @State private var showSettleSheet = false
    @State private var showSuccessSheet = false
    @State private var selectedMethod: SettleMethod = .upi

    private let youOweAmount: Double = 420
    private let lastUpdatedText: String = "2h ago"

    private let suggestions: [(name: String, amount: Double)] = [
        ("Alex", 300),
        ("Sam", 120)
    ]

    private let expenses: [(icon: String, title: String, subtitle: String, amount: Int, positive: Bool, time: String)] = [
        ("fork.knife", "Dinner", "You paid", 420, false, "2h ago"),
        ("car.fill", "Uber", "Paid by Alex", 180, true, "Yesterday"),
        ("cart.fill", "Groceries", "You paid", 270, false, "2 days ago")
    ]

    private var settleTotal: Int {
        suggestions.reduce(0) { $0 + Int($1.amount) }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {

                heroCard

                // ✅ FAIRNESS CARD (REAL ONE)
                GroupHealthCard(
                    score: 78,
                    members: [
                        .init(name: "Neel", delta: 520),
                        .init(name: "Alex", delta: -410)
                    ]
                )

                settlementCard
                recentExpensesCard

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 110)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { bottomCTA }
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView(groupName: groupName)
        }
        .sheet(isPresented: $showSettleSheet) {
            settleSheet
        }
        .sheet(isPresented: $showSuccessSheet) {
            settleSuccessSheet
        }
    }

    // MARK: Hero

    private var heroCard: some View {
        card {
            VStack(alignment: .leading, spacing: 10) {
                Text(groupName).font(.title2.bold())
                Text("You owe ₹\(Int(youOweAmount))")
                    .font(.headline)
                    .foregroundStyle(.red)

                Button {
                    showAddExpense = true
                } label: {
                    Label("Add Expense", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    // MARK: Settlement

    private var settlementCard: some View {
        card {
            VStack(alignment: .leading, spacing: 10) {
                Label("Suggested settlement", systemImage: "sparkles")
                    .font(.headline)

                ForEach(suggestions, id: \.name) { s in
                    HStack {
                        Text("Pay \(s.name)")
                        Spacer()
                        Text("₹\(Int(s.amount))").font(.headline)
                    }
                }
            }
        }
    }

    // MARK: Expenses

    private var recentExpensesCard: some View {
        card {
            VStack(alignment: .leading, spacing: 10) {
                Text("Recent expenses").font(.headline)

                ForEach(expenses, id: \.title) { e in
                    HStack {
                        Image(systemName: e.icon)
                        VStack(alignment: .leading) {
                            Text(e.title).bold()
                            Text(e.subtitle).font(.footnote).foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("₹\(e.amount)")
                                .foregroundStyle(e.positive ? .green : .red)
                            Text(e.time).font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: Bottom CTA

    private var bottomCTA: some View {
        Button {
            showSettleSheet = true
        } label: {
            HStack {
                Text("Settle Now").bold()
                Spacer()
                Text("₹\(settleTotal)").bold()
            }
            .padding()
            .foregroundStyle(.white)
            .background(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    // MARK: Sheets

    private var settleSheet: some View {
        NavigationStack {
            Text("Settlement flow coming next")
                .navigationTitle("Settle")
        }
    }

    private var settleSuccessSheet: some View {
        NavigationStack {
            Text("Settled successfully")
        }
    }

    // MARK: Card Helper

    @ViewBuilder
    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: .black.opacity(0.05), radius: 10, y: 6)
    }
}

private enum SettleMethod {
    case upi, card, cash
}
