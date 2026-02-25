import SwiftUI

struct ChangePasswordView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?

    var body: some View {

        Form {

            Section(header: Text("Current Password")) {
                SecureField("Enter current password", text: $currentPassword)
            }

            Section(header: Text("New Password")) {
                SecureField("Enter new password", text: $newPassword)
                SecureField("Confirm new password", text: $confirmPassword)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }

            if let successMessage {
                Section {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .font(.footnote)
                }
            }

            Section {
                Button {
                    Task { await changePassword() }
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Update Password")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(
                    isLoading ||
                    currentPassword.isEmpty ||
                    newPassword.isEmpty ||
                    confirmPassword.isEmpty
                )
            }
        }
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Logic

    private func changePassword() async {

        errorMessage = nil
        successMessage = nil

        guard newPassword == confirmPassword else {
            errorMessage = "New passwords do not match"
            return
        }

        isLoading = true

        do {
            try await APIClient.shared.changePassword(
                currentPassword: currentPassword,
                newPassword: newPassword
            )

            successMessage = "Password updated successfully"

            currentPassword = ""
            newPassword = ""
            confirmPassword = ""

        } catch {
            errorMessage = "Failed to update password"
        }

        isLoading = false
    }
}
