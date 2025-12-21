import SwiftUI

struct AddExpenseView: View {
    let groupName: String

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var expenseStore: ExpenseStore

    @State private var title: String = ""
    @State private var amountText: String = ""
    @State private var paidBy: String = "You"

    @State private var showSplitEditor = false
    @State private var splitResult: SplitResult?

    var body: some View {
        NavigationStack {
            Form {
                Section("Group") {
                    Text(groupName)
                        .foregroundStyle(.secondary)
                }

                Section("Expense Details") {
                    TextField("Title (e.g. Dinner)", text: $title)

                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)

                    Picker("Paid by", selection: $paidBy) {
                        Text("You").tag("You")
                        Text("Alex").tag("Alex")
                        Text("Sam").tag("Sam")
                    }
                }

                Section {
                    Button {
                        showSplitEditor = true
                    } label: {
                        HStack {
                            Text("Split")
                            Spacer()
                            Text(splitSummary)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(title.isEmpty || amountText.isEmpty)
                }
            }
            .sheet(isPresented: $showSplitEditor) {
                SplitEditorView(
                    totalAmount: Double(amountText) ?? 0
                ) { result in
                    splitResult = result
                }
            }
        }
    }

    // MARK: - Save

    private func saveExpense() {
        let total = Double(amountText) ?? 0

        let splits = splitResult?.splits ?? [
            ParticipantSplit(
                name: "Everyone",
                amount: total
            )
        ]

        let expense = Expense(
            id: UUID(),
            groupName: groupName,
            title: title,
            totalAmount: total,
            paidBy: paidBy,
            splits: splits,
            createdAt: Date()
        )

        expenseStore.add(expense)
        dismiss()
    }

    private var splitSummary: String {
        guard let splitResult else { return "Equal" }
        return "\(splitResult.splits.count) people"
    }
}
