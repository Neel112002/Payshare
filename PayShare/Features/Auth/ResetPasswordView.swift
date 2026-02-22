import SwiftUI

struct ResetPasswordView: View {

    let token: String   // 👈 Accept token from previous screen

    @Environment(\.dismiss) private var dismiss

    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    @State private var isLoading = false
    @State private var message: String?
    @State private var errorMessage: String?

    private var passwordRules: [PasswordRule] {
        PasswordValidator.validate(newPassword)
    }

    private var isPasswordValid: Bool {
        passwordRules.allSatisfy { $0.isValid }
    }

    private var doPasswordsMatch: Bool {
        !confirmPassword.isEmpty && newPassword == confirmPassword
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                Text("Reset Password")
                    .font(.largeTitle.bold())

                SecureField("New Password", text: $newPassword)
                    .textFieldStyle(.roundedBorder)

                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(passwordRules) { rule in
                        HStack {
                            Image(systemName: rule.isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(rule.isValid ? .green : .red)

                            Text(rule.description)
                                .font(.footnote)
                                .foregroundColor(rule.isValid ? .green : .red)
                        }
                    }

                    if !confirmPassword.isEmpty {
                        HStack {
                            Image(systemName: doPasswordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(doPasswordsMatch ? .green : .red)

                            Text("Passwords match")
                                .font(.footnote)
                                .foregroundColor(doPasswordsMatch ? .green : .red)
                        }
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                if let message {
                    Text(message)
                        .foregroundColor(.green)
                        .font(.footnote)
                }

                Button {
                    Task { await resetPassword() }
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Reset Password")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    newPassword.isEmpty ||
                    confirmPassword.isEmpty ||
                    !isPasswordValid ||
                    !doPasswordsMatch ||
                    isLoading
                )

                Spacer()
            }
            .padding()
        }
    }

    private func resetPassword() async {
        isLoading = true
        errorMessage = nil
        message = nil

        do {
            try await APIClient.shared.resetPassword(
                token: token,
                newPassword: newPassword
            )

            message = "Password successfully reset 🎉"

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }

        } catch {
            errorMessage = "Failed to reset password"
        }

        isLoading = false
    }
}
