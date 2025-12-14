import SwiftUI

struct SplitEditorView: View {
    enum SplitMode: String, CaseIterable, Identifiable {
        case equal = "Equal"
        case exact = "Exact"
        case percent = "Percent"
        var id: String { rawValue }
    }

    let members: [String]
    @Binding var mode: SplitMode

    // Exact amounts per member
    @Binding var exact: [String: Double]

    // Percent per member (0-100)
    @Binding var percent: [String: Double]

    let totalAmount: Double

    private var equalShare: Double {
        guard !members.isEmpty else { return 0 }
        return totalAmount / Double(members.count)
    }

    var body: some View {
        VStack(spacing: 12) {
            Picker("Split", selection: $mode) {
                ForEach(SplitMode.allCases) { m in
                    Text(m.rawValue).tag(m)
                }
            }
            .pickerStyle(.segmented)

            if mode == .equal {
                List {
                    ForEach(members, id: \.self) { m in
                        HStack {
                            Text(m)
                            Spacer()
                            Text(currency(equalShare))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(height: min(300, CGFloat(members.count) * 52))

            } else if mode == .exact {
                List {
                    ForEach(members, id: \.self) { m in
                        HStack {
                            Text(m)
                            Spacer()
                            TextField("0", value: bindingExact(m), format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 120)
                        }
                    }

                    HStack {
                        Text("Remaining")
                        Spacer()
                        Text(currency(remainingExact))
                            .foregroundStyle(remainingExact == 0 ? .green : .red)
                    }
                }
                .frame(height: min(340, CGFloat(members.count + 1) * 52))

            } else {
                List {
                    ForEach(members, id: \.self) { m in
                        HStack {
                            Text(m)
                            Spacer()
                            TextField("0", value: bindingPercent(m), format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("%").foregroundStyle(.secondary)
                        }
                    }

                    HStack {
                        Text("Total %")
                        Spacer()
                        Text("\(Int(totalPercent))%")
                            .foregroundStyle(totalPercent == 100 ? .green : .red)
                    }
                }
                .frame(height: min(340, CGFloat(members.count + 1) * 52))
            }
        }
    }

    private var remainingExact: Double {
        let sum = members.reduce(0.0) { $0 + (exact[$1] ?? 0) }
        return (totalAmount - sum).roundedTo2()
    }

    private var totalPercent: Double {
        members.reduce(0.0) { $0 + (percent[$1] ?? 0) }.roundedTo2()
    }

    private func bindingExact(_ member: String) -> Binding<Double> {
        Binding<Double>(
            get: { exact[member] ?? 0 },
            set: { exact[member] = $0 }
        )
    }

    private func bindingPercent(_ member: String) -> Binding<Double> {
        Binding<Double>(
            get: { percent[member] ?? 0 },
            set: { percent[member] = $0 }
        )
    }

    private func currency(_ value: Double) -> String {
        "₹" + String(format: "%.2f", value)
    }
}

private extension Double {
    func roundedTo2() -> Double {
        (self * 100).rounded() / 100
    }
}
