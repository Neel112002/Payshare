import SwiftUI

struct GroupListView: View {

    // MARK: - TEMP MOCK DATA (until backend list endpoint)
    private let groups: [Group] = [
        Group(id: UUID(), name: "Goa Trip", balance: -420, fairnessScore: 72),
        Group(id: UUID(), name: "Flatmates", balance: 860, fairnessScore: 88),
        Group(id: UUID(), name: "Office Lunch", balance: 0, fairnessScore: 95)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {

                    if groups.isEmpty {
                        emptyState
                    } else {
                        ForEach(groups) { group in
                            NavigationLink {
                                // ✅ FIXED: pass BOTH groupId + groupName
                                GroupDetailView(
                                    groupId: group.id,
                                    groupName: group.name
                                )
                            } label: {
                                groupCard(group)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 100)
            }
            .navigationTitle("Groups")
        }
    }

    // MARK: - Group Card

    private func groupCard(_ group: Group) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(group.name)
                .font(.headline)

            Text("Fairness score: \(group.fairnessScore)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .card()
    }

    // MARK: - Empty State

    private var emptyState: some View {
        Text("No groups yet")
            .foregroundStyle(.secondary)
    }
}
