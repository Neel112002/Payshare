import SwiftUI

struct AddExpenseView: View {

    // MARK: - Inputs
    let groupName: String
    @Environment(\.dismiss) private var dismiss

    // MARK: - Form state
    @State private var titleText: String = ""
    @State private var amountText: String = ""
    @State private var paidByYou: Bool = true

    // MARK: - Impact preview
    @State private var impactScore: Int?

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Group
                Section("Group") {
                    Text(groupName)
                        .font(.headline)
                }

                // MARK: - Expense
                Section("Expense details") {
                    TextField("Title (e.g., Dinner)", text: $titleText)

                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                        .onChange(of: amountText) { _ in
                            calculateImpact()
                        }

                    Toggle("Paid by you", isOn: $paidByYou)
                }

                // MARK: - Impact Preview (THE MAGIC)
                if let impactScore {
                    Section {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.green)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Expense impact")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text("This will improve group balance by ~\(impactScore)%")
                                    .font(.footnote.bold())
                                    .foregroundStyle(.green)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                // Cancel
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                // Save
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExpense()
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        !titleText.isEmpty && Double(amountText) != nil
    }

    // MARK: - Impact logic (frontend-only for now)

    private func calculateImpact() {
        guard let amount = Double(amountText), amount > 0 else {
            impactScore = nil
            return
        }

        /*
         Simple heuristic (frontend mock):
         Bigger expenses usually have more balancing impact.
         This WILL be replaced by backend logic later.
        */
        let rawScore = Int(amount / 10)
        impactScore = min(max(rawScore, 3), 25)
    }

    // MARK: - Save (mock)

    private func saveExpense() {
        print("""
        Expense saved:
        Title: \(titleText)
        Amount: \(amountText)
        Paid by you: \(paidByYou)
        Impact: \(impactScore ?? 0)%
        """)
    }
}
