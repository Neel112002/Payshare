import SwiftUI

struct EditProfileView: View {

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var email: String = ""

    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {

        Form {

            Section(header: Text("Name")) {
                TextField("Enter name", text: $name)
            }

            Section(header: Text("Email")) {
                TextField("Enter email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }

            Section {
                Button {
                    Task { await updateProfile() }
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(isLoading || name.isEmpty || email.isEmpty)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            name = appState.currentUser?.name ?? ""
            email = appState.currentUser?.email ?? ""
        }
    }

    // MARK: - Logic

    private func updateProfile() async {

        errorMessage = nil
        isLoading = true

        do {
            let updatedUser = try await APIClient.shared.updateProfile(
                name: name,
                email: email
            )

            await MainActor.run {
                appState.currentUser = updatedUser
                dismiss()
            }

        } catch {
            errorMessage = "Failed to update profile"
        }

        isLoading = false
    }
}
