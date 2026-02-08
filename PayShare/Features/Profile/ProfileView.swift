import SwiftUI

struct ProfileView: View {

    @EnvironmentObject private var profileStore: ProfileStore

    var body: some View {
        NavigationStack {
            SwiftUI.Group {
                if profileStore.isLoading {
                    ProgressView("Loading profile...")
                } else if let user = profileStore.user {
                    profileContent(user)
                } else {
                    Text("Not logged in")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Profile")
            .task {
                await profileStore.loadProfile()
            }
        }
    }

    private func profileContent(_ user: User) -> some View {
        VStack(spacing: 16) {
            Text(user.name)
                .font(.title2.bold())

            Text(user.email)
                .foregroundStyle(.secondary)

            Button(role: .destructive) {
                profileStore.logout()
            } label: {
                Text("Logout")
            }

            Spacer()
        }
        .padding()
    }
}
