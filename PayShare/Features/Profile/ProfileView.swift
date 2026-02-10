import SwiftUI

struct ProfileView: View {

    @EnvironmentObject private var profileStore: ProfileStore

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Profile")
                .task {
                    // Load profile once when view appears
                    if profileStore.user == nil {
                        await profileStore.loadProfile()
                    }
                }
        }
    }

    // MARK: - Main Content

    @ViewBuilder
    private var content: some View {
        if profileStore.isLoading {
            loadingView
        } else if let user = profileStore.user {
            profileContent(user)
        } else {
            loggedOutView
        }
    }

    // MARK: - States

    private var loadingView: some View {
        VStack {
            ProgressView("Loading profile...")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var loggedOutView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Not logged in")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Profile Content

    private func profileContent(_ user: User) -> some View {
        VStack(spacing: 16) {

            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.blue)

            Text(user.name)
                .font(.title2.bold())

            Text(user.email)
                .foregroundStyle(.secondary)

            Divider()
                .padding(.vertical)

            Button(role: .destructive) {
                profileStore.logout()
            } label: {
                Text("Logout")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .top)
    }
}
