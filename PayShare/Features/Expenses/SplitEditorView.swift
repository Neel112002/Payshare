import SwiftUI

struct SplitEditorView: View {
    let totalAmount: Double

    @Environment(\.dismiss) private var dismiss

    @State private var splits: [SplitRow] = [
        .init(name: "You", isIncluded: true, amount: 0),
        .init(name: "Alex", isIncluded: true, amount: 0),
        .init(name: "Sam", isIncluded: true, amount: 0)
    ]

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Total
                Section("Total") {
                    Text("₹\(Int(totalAmount))")
                        .font(.headline)
                }

                // MARK: - Split Members
                Section("Split Between") {
                    ForEach($splits) { $split in
                        HStack {
                            Toggle(split.name, isOn: $split.isIncluded)
                                .toggleStyle(.switch)

                            Spacer()

                            TextField(
                                "₹0",
                                value: $split.amount,
                                format: .number
                            )
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .disabled(!split.isIncluded)
                            .foregroundStyle(
                                split.isIncluded ? .primary : .secondary
                            )
                        }
                    }
                }

                // MARK: - Actions
                Section {
                    Button("Split Equally") {
                        splitEqually()
                    }
                    .disabled(includedSplits.count == 0)
                }
            }
            .navigationTitle("Split")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var includedSplits: [Int] {
        splits.indices.filter { splits[$0].isIncluded }
    }

    private func splitEqually() {
        let active = includedSplits
        guard !active.isEmpty else { return }

        let equalAmount = totalAmount / Double(active.count)

        for i in splits.indices {
            splits[i].amount = splits[i].isIncluded ? equalAmount : 0
        }
    }
}

struct SplitRow: Identifiable {
    let id = UUID()
    let name: String
    var isIncluded: Bool
    var amount: Double
}
