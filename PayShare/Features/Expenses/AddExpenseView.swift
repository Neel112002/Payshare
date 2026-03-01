import SwiftUI

struct AddExpenseView: View {
    let groupId: UUID
    let groupName: String
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var amountText: String = ""
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
        print("🔥 Save tapped")

        guard let total = Double(amountText) else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            try await APIClient.shared.createExpense(
                groupId: groupId,
                title: title,
                totalAmount: total
            )

            dismiss()

        } catch {
            print("❌ Failed to save expense:", error)
        }
    }
}
