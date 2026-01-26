import SwiftUI

struct SplitEditorView: View {

    let totalAmount: Double
    let onSave: (SplitResult) -> Void   // ✅ FIXED TYPE

    @Environment(\.dismiss) private var dismiss

    @State private var from: String = "You"
    @State private var to: String = "Alex"

    var body: some View {
        NavigationStack {
            Form {
                Section("From") {
                    TextField("From", text: $from)
                }

                Section("To") {
                    TextField("To", text: $to)
                }

                Section("Amount") {
                    Text("₹\(Int(totalAmount))")
                        .font(.headline)
                }
            }
            .navigationTitle("Split")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onSave(
                            SplitResult(
                                from: from,
                                to: to,
                                amount: totalAmount
                            )
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}
