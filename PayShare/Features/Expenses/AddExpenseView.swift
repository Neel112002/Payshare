import SwiftUI

struct AddExpenseView: View {
    let groupName: String

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var amountText: String = ""
    @State private var paidBy: String = "You"

    @State private var showSplitEditor = false

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
                            Text("Equal")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // UI-only for Phase 1
                        dismiss()
                    }
                    .disabled(title.isEmpty || amountText.isEmpty)
                }
            }
            .sheet(isPresented: $showSplitEditor) {
                SplitEditorView(
                    totalAmount: Double(amountText) ?? 0
                )
            }
        }
    }
}
