import SwiftUI

struct AddExpenseView: View {
    let groupId: UUID
    let groupName: String

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var amountText: String = ""
    @State private var paidBy: String = "You"
    @State private var isSaving = false

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
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await saveExpense() }
                    }
                    .disabled(title.isEmpty || amountText.isEmpty || isSaving)
                }
            }
        }
    }

    // MARK: - Save Expense (BACKEND)

    @MainActor
    private func saveExpense() async {
        guard let total = Double(amountText) else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            try await APIClient.shared.createExpense(
                groupId: groupId,
                title: title,
                totalAmount: total,
                paidBy: paidBy
            )
            dismiss()
        } catch {
            print("Failed to save expense:", error)
        }
    }
}
