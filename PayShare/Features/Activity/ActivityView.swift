import SwiftUI

struct ActivityView: View {
    struct ActivityItem: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let amount: String
        let isPositive: Bool
        let time: String
    }

    let items: [ActivityItem] = [
        .init(title: "Dinner", subtitle: "Trip to Toronto • paid by You", amount: "+₹140", isPositive: true, time: "2h ago"),
        .init(title: "Uber", subtitle: "Roommates • paid by Alex", amount: "-₹60", isPositive: false, time: "Yesterday"),
        .init(title: "Groceries", subtitle: "Roommates • paid by You", amount: "+₹90", isPositive: true, time: "2 days ago")
    ]

    var body: some View {
        List {
            Section {
                ForEach(items) { item in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(.gray.opacity(0.15))
                            Image(systemName: "receipt")
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 42, height: 42)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title).font(.headline)
                            Text(item.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(item.amount)
                                .font(.headline)
                                .foregroundStyle(item.isPositive ? .green : .red)
                            Text(item.time)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
            } header: {
                Text("Recent Activity")
            }
        }
        .navigationTitle("Activity")
    }
}
