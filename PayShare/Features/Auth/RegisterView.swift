import SwiftUI

struct RegisterView: View {

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    // MARK: - Password Rules

    private var passwordRules: [PasswordRule] {
        PasswordValidator.validate(password)
    }

    private var isPasswordValid: Bool {
        passwordRules.allSatisfy { $0.isValid }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                Text("Create Account")
                    .font(.largeTitle.bold())

                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                // 🔐 Live Password Validation UI
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
                }
                .padding(.top, 4)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task {
                        await register()
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    name.isEmpty ||
                    email.isEmpty ||
                    password.isEmpty ||
                    !isPasswordValid ||
                    isLoading
                )

                Spacer()
            }
            .padding()
        }
    }

    // MARK: - Register Logic

    private func register() async {
        isLoading = true
        errorMessage = nil

        do {
            try await APIClient.shared.register(
                name: name,
                email: email,
                password: password
            )

            await appState.login(email: email, password: password)

            dismiss()

        } catch {
            // 🔥 Handle backend validation errors
            if let error = error as? URLError {
                errorMessage = "Network error"
            } else {
                errorMessage = parseBackendError(error)
            }
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

        return "Failed to create account"
    }
}
