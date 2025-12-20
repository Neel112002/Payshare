import SwiftUI

struct GroupListView: View {

    // MARK: - Mock Group Model (frontend only)
    struct Group: Identifiable {
        let id = UUID()
        let name: String
        let balance: Int        // + = you’re owed, - = you owe
        let fairnessScore: Int  // 0–100
    }

    // MARK: - Mock Data
    private let groups: [Group] = [
        .init(name: "Goa Trip", balance: -420, fairnessScore: 72),
        .init(name: "Flatmates", balance: 860, fairnessScore: 88),
        .init(name: "Office Lunch", balance: 0, fairnessScore: 95)
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
                                GroupDetailView(groupName: group.name)
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
            .safeAreaInset(edge: .bottom) {
                createGroupButton
            }
        }
    }

    // MARK: - Group Card

    private func groupCard(_ group: Group) -> some View {
        HStack(spacing: 14) {

            // Group icon
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(group.name.prefix(1))
                        .font(.headline.bold())
                        .foregroundStyle(.blue)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(group.name)
                    .font(.headline)

                HStack(spacing: 6) {
                    Text(balanceText(group.balance))
                        .font(.subheadline.bold())
                        .foregroundStyle(balanceColor(group.balance))

                    Text("• Fairness \(group.fairnessScore)%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 42))
                .foregroundStyle(.secondary)

            Text("No groups yet")
                .font(.headline)

            Text("Create a group to start sharing expenses.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 100)
    }

    // MARK: - Create Group Button

    private var createGroupButton: some View {
        Button {
            // Future: create group flow
        } label: {
            HStack {
                Image(systemName: "plus")
                Text("Create Group")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(.white)
            .background(LinearGradient(
                colors: [.blue, .cyan],
                startPoint: .leading,
                endPoint: .trailing
            ))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(.ultraThinMaterial)
    }

    // MARK: - Helpers

    private func balanceText(_ balance: Int) -> String {
        if balance > 0 {
            return "You’re owed ₹\(balance)"
        } else if balance < 0 {
            return "You owe ₹\(abs(balance))"
        } else {
            return "Settled"
        }
    }

    private func balanceColor(_ balance: Int) -> Color {
        if balance > 0 { return .green }
        if balance < 0 { return .red }
        return .secondary
    }
}
