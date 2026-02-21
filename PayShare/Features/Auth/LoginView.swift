import SwiftUI

struct LoginView: View {

    @EnvironmentObject private var appState: AppState

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var showRegister = false
    @State private var showForgotPassword = false

    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            Text("PayShare")
                .font(.largeTitle.bold())

            Text("Login")
                .font(.title3)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Button(action: login) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || email.isEmpty || password.isEmpty)

            // MARK: - Auth Navigation

            VStack(spacing: 12) {

                Button("Create Account") {
                    showRegister = true
                }

                Button("Forgot Password?") {
                    showForgotPassword = true
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showRegister) {
            RegisterView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }

    // MARK: - Login Logic

    private func login() {
        guard !email.isEmpty, !password.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                await appState.login(email: email, password: password)

                if !appState.isLoggedIn {
                    errorMessage = "Invalid email or password"
                }

            } catch {
                errorMessage = "Something went wrong"
            }

            isLoading = false
        }
    }
}
