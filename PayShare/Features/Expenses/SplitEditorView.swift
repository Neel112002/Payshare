import SwiftUI

struct SplitEditorView: View {

    let totalAmount: Double
    let onSave: (SplitResult) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var splits: [SplitRow] = [
        .init(name: "You", isIncluded: true, amount: 0),
        .init(name: "Alex", isIncluded: true, amount: 0),
        .init(name: "Sam", isIncluded: true, amount: 0)
    ]

    var body: some View {
        NavigationStack {
            Form {

                Section("Total") {
                    Text("₹\(Int(totalAmount))")
                        .font(.headline)
                }

                Section("Split Between") {
                    ForEach($splits) { $split in
                        HStack {
                            Toggle(split.name, isOn: $split.isIncluded)

                            Spacer()

                            TextField(
                                "₹0",
                                value: $split.amount,
                                format: .number
                            )
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                            .disabled(!split.isIncluded)
                        }
                    }
                }

                Section {
                    Button("Split Equally") {
                        splitEqually()
                    }
                }
            }
            .navigationTitle("Split")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        save()
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func splitEqually() {
        let active = splits.filter { $0.isIncluded }
        guard !active.isEmpty else { return }

        let perPerson = totalAmount / Double(active.count)

        for i in splits.indices {
            splits[i].amount = splits[i].isIncluded ? perPerson : 0
        }
    }

    private func save() {
        let participants = splits
            .filter { $0.isIncluded }
            .map {
                ParticipantSplit(
                    name: $0.name,
                    amount: $0.amount
                )
            }

        let result = SplitResult(
            total: totalAmount,
            splits: participants
        )

        onSave(result)
        dismiss()
    }
}

// MARK: - Local UI Model

struct SplitRow: Identifiable {
    let id = UUID()
    let name: String
    var isIncluded: Bool
    var amount: Double
}
