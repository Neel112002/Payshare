import SwiftUI

struct ProfileView: View {

    @EnvironmentObject private var profileStore: ProfileStore
    @EnvironmentObject private var authStore: AuthStore

    var body: some View {
        ScrollView {
            if profileStore.isLoading {
                ProgressView()
                    .padding(.top, 60)
            } else if let user = profileStore.user {
                profileContent(user)
            } else {
                Text("No profile data")
                    .foregroundStyle(.secondary)
                    .padding(.top, 60)
            }
        }
        .navigationTitle("Profile")
        .task {
            await profileStore.loadProfile()
        }
    }

    private func profileContent(_ user: User) -> some View {
        VStack(spacing: 24) {

            VStack(alignment: .leading, spacing: 6) {
                Text(user.name)
                    .font(.title2.bold())

                Text(user.email)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .card()

            VStack(alignment: .leading, spacing: 12) {
                Text("Currency: \(user.currency)")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .card()

            Button(role: .destructive) {
                authStore.logout()
            } label: {
                Text("Logout")
                    .frame(maxWidth: .infinity)
            }
            .card()
        }
        .padding()
    }
}
