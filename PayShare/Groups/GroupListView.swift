import SwiftUI

struct GroupListView: View {
    struct GroupRow: Identifiable {
        let id = UUID()
        let name: String
        let subtitle: String
        let amountText: String
        let isOwed: Bool
    }

    let groups: [GroupRow] = [
        .init(name: "Trip to Toronto", subtitle: "3 people • 12 expenses", amountText: "You owe ₹420", isOwed: true),
        .init(name: "Roommates", subtitle: "4 people • 8 expenses", amountText: "You are owed ₹190", isOwed: false),
        .init(name: "Friday Dinner", subtitle: "5 people • 3 expenses", amountText: "Settled up", isOwed: false),
    ]

    var body: some View {
        List {
            Section {
                ForEach(groups) { g in
                    NavigationLink {
                        GroupDetailView(groupName: g.name)
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle().fill(.blue.opacity(0.15))
                                Text(String(g.name.prefix(1)))
                                    .font(.headline)
                                    .foregroundStyle(.blue)
                            }
                            .frame(width: 44, height: 44)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(g.name)
                                    .font(.headline)
                                Text(g.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(g.amountText)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(g.isOwed ? .red : .green)
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(.vertical, 6)
                    }
                }
            } header: {
                Text("Your Groups")
            }
        }
        .navigationTitle("PayShare")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // later: create group
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}
