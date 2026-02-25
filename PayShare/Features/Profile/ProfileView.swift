import SwiftUI

struct ProfileView: View {

    @EnvironmentObject var appState: AppState

    var body: some View {

        NavigationStack {
            List {

                // MARK: - User Section

                Section {
                    VStack(spacing: 12) {

                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text(appState.currentUser?.name ?? "User")
                            .font(.title3.bold())

                        Text(appState.currentUser?.email ?? "")
                            .font(.footnote)
                            .foregroundColor(.gray)

                        Button("Edit Profile") {
                            // Future edit screen
                        }
                        .font(.footnote)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                .listRowBackground(Color.clear)

                // MARK: - Account Section

                Section("Account") {

                    NavigationLink {
                        Text("Change Password Screen")
                    } label: {
                        Label("Change Password", systemImage: "lock.fill")
                    }

                    Button(role: .destructive) {
                        // Delete account action
                    } label: {
                        Label("Delete Account", systemImage: "trash")
                    }
                }

                // MARK: - Logout

                Section {
                    Button(role: .destructive) {
                        appState.logout()
                    } label: {
                        Text("Logout")
                            .frame(maxWidth: .infinity)
                    }
                }

                // MARK: - Version

                Section {
                    HStack {
                        Spacer()
                        Text("PayShare v1.0")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)

            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
        }
    }
}
