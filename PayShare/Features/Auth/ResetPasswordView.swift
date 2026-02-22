import SwiftUI

struct ResetPasswordView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var token: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    @State private var isLoading = false
    @State private var message: String?
    @State private var errorMessage: String?

    // MARK: - Password Rules

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

                TextField("Reset Token", text: $token)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                SecureField("New Password", text: $newPassword)
                    .textFieldStyle(.roundedBorder)

                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)

                // 🔐 Live Password Rules
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

                    // Confirm password check
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
                .padding(.top, 4)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }

                if let message {
                    Text(message)
                        .foregroundColor(.green)
                        .font(.footnote)
                }

                Button {
                    Task {
                        await resetPassword()
                    }
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
                    token.isEmpty ||
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

    // MARK: - Reset Logic

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

            // Optional: auto dismiss after success
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }

        } catch {
            errorMessage = parseBackendError(error)
        }

        isLoading = false
    }

    private func parseBackendError(_ error: Error) -> String {
        if let error = error as? NSError,
           let data = error.userInfo["data"] as? Data,
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let detail = json["detail"] {

            if let messages = detail as? [String] {
                return messages.joined(separator: "\n")
            }

            if let message = detail as? String {
                return message
            }
        }

        return "Failed to reset password"
    }
}
