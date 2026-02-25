import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var appState: AppState
    
    @State private var showDeleteAlert = false
    @State private var isDeleting = false

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

                        // ✅ EDIT PROFILE CONNECTED
                        NavigationLink {
                            EditProfileView()
                        } label: {
                            Text("Edit Profile")
                                .font(.footnote)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                .listRowBackground(Color.clear)

                // MARK: - Account Section

                Section("Account") {

                    NavigationLink {
                        ChangePasswordView()
                    } label: {
                        Label("Change Password", systemImage: "lock.fill")
                    }

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete Account", systemImage: "trash")
                    }
                }

                // MARK: - Logout Section

                Section {
                    Button(role: .destructive) {
                        appState.logout()
                    } label: {
                        Text("Logout")
                            .frame(maxWidth: .infinity)
                    }
                }

                // MARK: - Version Section

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
            .alert("Delete Account?",
                   isPresented: $showDeleteAlert) {

                Button("Delete", role: .destructive) {
                    Task { await deleteAccount() }
                }

                Button("Cancel", role: .cancel) { }

            } message: {
                Text("This action is permanent and cannot be undone.")
            }
        }
    }

    // MARK: - Delete Logic

    private func deleteAccount() async {

        isDeleting = true

        do {
            try await APIClient.shared.deleteAccount()

            await MainActor.run {
                appState.logout()
            }

        } catch {
            print("❌ Delete failed:", error)
        }

        isDeleting = false
    }
}
