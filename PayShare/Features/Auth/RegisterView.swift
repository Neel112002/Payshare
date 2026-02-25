import SwiftUI

struct RegisterView: View {

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    // MARK: - Password Validation

    private var passwordRules: [PasswordRule] {
        PasswordValidator.validate(password)
    }

    private var isPasswordValid: Bool {
        passwordRules.allSatisfy { $0.isValid }
    }

    var body: some View {
        ZStack {

            // Background
            LinearGradient(
                colors: [Color.blue.opacity(0.15), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {

                Spacer()

                VStack(spacing: 24) {

                    VStack(spacing: 8) {
                        Image(systemName: "person.badge.plus.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.blue)

                        Text("Create Account")
                            .font(.largeTitle.bold())
                    }

                    VStack(spacing: 16) {

                        TextField("Full Name", text: $name)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5)

                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5)

                        HStack {
                            if showPassword {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }

                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundStyle(.gray)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                    }

                    // 🔐 Live Password Rules
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password must contain:")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.bottom, 2)

                        ForEach(passwordRules) { rule in
                            HStack(spacing: 8) {

                                Image(systemName: rule.isValid ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(rule.isValid ? .green : .gray.opacity(0.5))
                                    .animation(.easeInOut(duration: 0.2), value: rule.isValid)

                                Text(rule.description)
                                    .font(.caption)
                                    .foregroundColor(rule.isValid ? .green : .gray)
                            }
                        }
                    }
                    .padding(.vertical, 4)

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task { await register() }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Sign Up")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .shadow(color: .blue.opacity(0.3), radius: 10)
                    .disabled(
                        name.isEmpty ||
                        email.isEmpty ||
                        password.isEmpty ||
                        !isPasswordValid ||
                        isLoading
                    )

                    Button("Already have an account? Login") {
                        dismiss()
                    }
                    .font(.footnote)
                    .foregroundStyle(.blue)
                }
                .padding(32)
                .background(Color.white.opacity(0.85))
                .cornerRadius(24)
                .padding()

                Spacer()
            }
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
            errorMessage = "Failed to create account"
        }

        isLoading = false
    }
}
