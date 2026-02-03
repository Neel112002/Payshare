import SwiftUI

struct GroupListView: View {

    // MARK: - State
    @State private var groups: [Group] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {

                    if isLoading {
                        ProgressView("Loading groups...")
                            .padding(.top, 80)

                    } else if let errorMessage {
                        errorState(errorMessage)

                    } else if groups.isEmpty {
                        emptyState

                    } else {
                        ForEach(groups) { group in
                            NavigationLink {
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
            .task {
                await loadGroups()
            }
        }
    }

    // MARK: - API

    @MainActor
    private func loadGroups() async {
        do {
            groups = try await APIClient.shared.fetchGroups()
            isLoading = false
        } catch {
            errorMessage = "Failed to load groups"
            isLoading = false
            print("❌ Group fetch error:", error)
        }
    }

    // MARK: - Group Card (UNCHANGED UI)

    private func groupCard(_ group: Group) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text(group.name)
                    .font(.headline)

                Spacer()

                fairnessBadge(group.fairnessScore)
            }

            Text(balanceText(group.balance))
                .font(.subheadline)
                .foregroundStyle(balanceColor(group.balance))
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Helpers (UNCHANGED)

    private func fairnessBadge(_ score: Int) -> some View {
        Text("\(score)%")
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(fairnessColor(score).opacity(0.15))
            .foregroundStyle(fairnessColor(score))
            .clipShape(Capsule())
    }

    private func fairnessColor(_ score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }

    private func balanceText(_ balance: Double) -> String {
        if balance == 0 {
            return "All settled 🎉"
        } else if balance < 0 {
            return "You owe ₹\(Int(abs(balance)))"
        } else {
            return "You are owed ₹\(Int(balance))"
        }
    }

    private func balanceColor(_ balance: Double) -> Color {
        balance < 0 ? .red : .green
    }

    // MARK: - States

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)

            Text(message)
                .font(.headline)
        }
        .padding(.top, 80)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("No groups yet")
                .font(.headline)

            Text("Create a group to start sharing expenses.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 80)
    }
}

