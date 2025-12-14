import SwiftUI

struct AddExpenseView: View {
    let groupName: String
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var amountText = ""
    @State private var paidBy = "You"

    private let members = ["You", "Alex", "Sam"]

    @State private var splitMode: SplitEditorView.SplitMode = .equal
    @State private var exact: [String: Double] = [:]
    @State private var percent: [String: Double] = [:]

    private var amount: Double {
        Double(amountText.replacingOccurrences(of: ",", with: "")) ?? 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Group") {
                    Text(groupName)
                }

                Section("Expense") {
                    TextField("Title (e.g., Dinner)", text: $title)

                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)

                    Picker("Paid by", selection: $paidBy) {
                        ForEach(members, id: \.self) { Text($0) }
                    }
                }

                Section("Split") {
                    SplitEditorView(
                        members: members,
                        mode: $splitMode,
                        exact: $exact,
                        percent: $percent,
                        totalAmount: amount
                    )
                    .padding(.vertical, 6)
                }

                Section {
                    Button("Save Expense") {
                        // Frontend-only: print what user selected
                        print("Expense:", title, "Amount:", amount, "PaidBy:", paidBy, "Mode:", splitMode.rawValue)
                        print("Exact:", exact)
                        print("Percent:", percent)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(title.isEmpty || amount <= 0)
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onAppear {
            // Defaults for split inputs
            for m in members {
                exact[m] = 0
                percent[m] = 0
            }
        }
    }
}
