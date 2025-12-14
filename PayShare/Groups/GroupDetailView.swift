import SwiftUI

struct GroupDetailView: View {
    let groupName: String

    @State private var showAddExpense = false

    // Settle flow
    @State private var showSettleSheet = false
    @State private var showSuccessSheet = false
    @State private var selectedMethod: SettleMethod = .upi
    @State private var settleNoteText: String = "Settling now to close balances."

    // Mock group summary
    private let youOweAmount: Double = 420
    private let lastUpdatedText: String = "2h ago"

    // Mock suggested settlement
    private let suggestions: [(name: String, amount: Double)] = [
        ("Alex", 300),
        ("Sam", 120)
    ]

    // A) fairness mock
    private let fairness = FairnessModel(
        score: 0.78,
        overpayerName: "Neel",
        overpayerAmount: 520,
        underpayerName: "Alex",
        underpayerAmount: 410,
        insight: "Neel has paid more than average in the last 7 days."
    )

    // B) budget mode
    @State private var budgetEnabled = true
    @State private var dailyBudget: Double = 1200
    private let todaySpent: Double = 860

    private struct ExpenseRow: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let subtitle: String
        let amount: Double
        let isPositive: Bool
        let timeText: String
    }

    private let expenses: [ExpenseRow] = [
        .init(icon: "fork.knife", title: "Dinner", subtitle: "You paid", amount: 420, isPositive: false, timeText: "2h ago"),
        .init(icon: "car.fill", title: "Uber", subtitle: "Paid by Alex", amount: 180, isPositive: true, timeText: "Yesterday"),
        .init(icon: "cart.fill", title: "Groceries", subtitle: "You paid", amount: 270, isPositive: false, timeText: "2 days ago")
    ]

    private var settleTotal: Double { suggestions.reduce(0) { $0 + $1.amount } }
    private var budgetProgress: Double { min(1, todaySpent / max(dailyBudget, 1)) }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                heroCard
                fairnessCard
                budgetCard
                settlementCard
                recentExpensesCard

                // extra scroll space so last card isn't hidden behind bottom CTA
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 110)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)

        // ✅ FIX: keep Settle Now ABOVE tab bar
        .safeAreaInset(edge: .bottom) {
            bottomCTA
        }

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

    // MARK: - HERO (smaller + cleaner)

    private var heroCard: some View {
        card(padded: false) {
            ZStack {
                LinearGradient(colors: [.blue, .cyan],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.white.opacity(0.30))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Text(String(groupName.prefix(1)).uppercased())
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(groupName)
                                .font(.headline.bold())
                                .foregroundStyle(.white)

                            HStack(spacing: 8) {
                                Text("You owe")
                                    .foregroundStyle(.white.opacity(0.85))

                                Text("₹\(Int(youOweAmount))")
                                    .font(.headline.bold())
                                    .foregroundStyle(.white)

                                Spacer()

                                Text("Updated \(lastUpdatedText)")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.85))
                            }
                        }
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "wand.and.stars")
                        Text("Smart plan reduces back-and-forth")
                        Spacer()
                        Text("Smart")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.18))
                            .clipShape(Capsule())
                    }
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.92))

                    Button {
                        showAddExpense = true
                    } label: {
                        Label("Add Expense", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.18))
                            .clipShape(Capsule())
                    }
                    .foregroundStyle(.white)
                }
                .padding(16)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }

    // MARK: - A) FAIRNESS

    private var fairnessCard: some View {
        card {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("Fairness Score", systemImage: "scale.3d")
                        .font(.headline)
                    Spacer()
                    fairnessBadge(score: fairness.score)
                }

                Text(fairness.insight)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Unbalanced").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Text("Balanced").font(.caption).foregroundStyle(.secondary)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 999)
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 10)

                            RoundedRectangle(cornerRadius: 999)
                                .fill(LinearGradient(colors: [.red, .orange, .green],
                                                     startPoint: .leading,
                                                     endPoint: .trailing))
                                .frame(width: geo.size.width * fairness.score, height: 10)
                        }
                    }
                    .frame(height: 10)

                    HStack(spacing: 10) {
                        miniPersonChip(name: fairness.overpayerName, text: "+₹\(Int(fairness.overpayerAmount))", tone: .orange)
                        miniPersonChip(name: fairness.underpayerName, text: "-₹\(Int(fairness.underpayerAmount))", tone: .blue)
                        Spacer()
                    }
                    .padding(.top, 4)
                }

                Button {
                    // later
                } label: {
                    HStack {
                        Text("View fairness insights")
                        Spacer()
                        Image(systemName: "chevron.right").font(.footnote.bold())
                    }
                }
                .buttonStyle(.plain)
                .font(.footnote.bold())
                .foregroundStyle(.blue)
                .padding(.top, 4)
            }
        }
    }

    // MARK: - B) BUDGET

    private var budgetCard: some View {
        card {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("Budget Mode", systemImage: "target")
                        .font(.headline)
                    Spacer()
                    Toggle("", isOn: $budgetEnabled).labelsHidden()
                }

                if budgetEnabled {
                    Text("Today spent ₹\(Int(todaySpent)) of ₹\(Int(dailyBudget))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    ProgressView(value: budgetProgress)
                        .tint(budgetProgress > 0.9 ? .red : .blue)

                    HStack {
                        Text("Daily limit").font(.footnote.bold())
                        Spacer()
                        Text("₹\(Int(dailyBudget))").font(.footnote.bold())
                    }

                    Slider(value: $dailyBudget, in: 300...5000, step: 50)

                    HStack(spacing: 10) {
                        quickBudgetPill("₹800") { dailyBudget = 800 }
                        quickBudgetPill("₹1200") { dailyBudget = 1200 }
                        quickBudgetPill("₹2000") { dailyBudget = 2000 }
                        Spacer()
                    }
                } else {
                    Text("Turn on Budget Mode to control spending.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Settlement card

    private var settlementCard: some View {
        card {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("Suggested settlement", systemImage: "sparkles")
                        .font(.headline)
                    Spacer()
                    Text("Auto")
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.12))
                        .clipShape(Capsule())
                }

                ForEach(suggestions.indices, id: \.self) { i in
                    let s = suggestions[i]
                    HStack {
                        Text("Pay \(s.name)")
                        Spacer()
                        Text("₹\(Int(s.amount))").font(.headline)
                    }
                    if i != suggestions.count - 1 { Divider() }
                }
            }
        }
    }

    // MARK: - Recent expenses

    private var recentExpensesCard: some View {
        card {
            VStack(alignment: .leading, spacing: 10) {
                Text("Recent expenses").font(.headline)

                ForEach(expenses) { e in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.gray.opacity(0.12))
                            .frame(width: 44, height: 44)
                            .overlay(Image(systemName: e.icon).foregroundStyle(.secondary))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(e.title).font(.headline)
                            Text(e.subtitle).font(.subheadline).foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("₹\(Int(e.amount))")
                                .font(.headline)
                                .foregroundStyle(e.isPositive ? .green : .red)
                            Text(e.timeText).font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                    if e.id != expenses.last?.id { Divider() }
                }
            }
        }
    }

    // MARK: - Bottom CTA (doesn't overlap tab bar)

    private var bottomCTA: some View {
        VStack(spacing: 10) {
            Button {
                showSettleSheet = true
            } label: {
                HStack {
                    Text("Settle Now").font(.headline)
                    Spacer()
                    Text("₹\(Int(settleTotal))").font(.headline.bold())
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .foregroundStyle(.white)
                .background(LinearGradient(colors: [.blue, .cyan],
                                           startPoint: .leading,
                                           endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
        .background(.ultraThinMaterial)
    }

    // MARK: - Sheets

    private var settleSheet: some View {
        NavigationStack {
            VStack(spacing: 12) {
                card {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("One-tap settlement").font(.headline)
                        Text("Pick a method and confirm.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        HStack {
                            Text("Total").foregroundStyle(.secondary)
                            Spacer()
                            Text("₹\(Int(settleTotal))").font(.title3.bold())
                        }
                    }
                }

                card {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Method").font(.headline)
                        Picker("Method", selection: $selectedMethod) {
                            ForEach(SettleMethod.allCases, id: \.self) { m in
                                Text(m.title).tag(m)
                            }
                        }
                        .pickerStyle(.segmented)

                        TextField("Note (optional)", text: $settleNoteText, axis: .vertical)
                            .lineLimit(2, reservesSpace: true)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                Spacer()

                Button {
                    showSettleSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showSuccessSheet = true
                    }
                } label: {
                    Text("Confirm & Settle")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Settle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { showSettleSheet = false }
                }
            }
        }
    }

    private var settleSuccessSheet: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)
                    .padding(.top, 20)

                Text("Settled!").font(.title2.bold())
                Text("Settled via \(selectedMethod.title).")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Done") { showSuccessSheet = false }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
            .padding(.horizontal, 16)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Success")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func card<Content: View>(padded: Bool = true, @ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(padded ? 16 : 0)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 6)
    }

    private func fairnessBadge(score: Double) -> some View {
        let title: String
        let bg: Color
        switch score {
        case 0..<0.45: title = "Skewed"; bg = .red.opacity(0.12)
        case 0.45..<0.75: title = "Okay"; bg = .orange.opacity(0.12)
        default: title = "Balanced"; bg = .green.opacity(0.12)
        }
        return Text("\(title) \(Int(score * 100))")
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(bg)
            .clipShape(Capsule())
    }

    private enum ChipTone { case orange, blue }

    private func miniPersonChip(name: String, text: String, tone: ChipTone) -> some View {
        let color: Color = (tone == .orange) ? .orange : .blue
        return HStack(spacing: 8) {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 26, height: 26)
                .overlay(Text(String(name.prefix(1))).font(.caption.bold()).foregroundStyle(color))
            VStack(alignment: .leading, spacing: 1) {
                Text(name).font(.caption.bold())
                Text(text).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func quickBudgetPill(_ text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.12))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .foregroundStyle(.blue)
    }
}

// MARK: - Supporting Models

private struct FairnessModel {
    let score: Double
    let overpayerName: String
    let overpayerAmount: Double
    let underpayerName: String
    let underpayerAmount: Double
    let insight: String
}

private enum SettleMethod: CaseIterable {
    case upi, card, cash
    var title: String {
        switch self {
        case .upi: return "UPI"
        case .card: return "Card"
        case .cash: return "Cash"
        }
    }
}
