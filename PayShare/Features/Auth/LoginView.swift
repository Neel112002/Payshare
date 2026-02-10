import SwiftUI

struct LoginView: View {

    @EnvironmentObject private var appState: AppState

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {

            Spacer()

            Text("PayShare")
                .font(.largeTitle.bold())

            Text("Login")
                .font(.title2)
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

            Button {
                login()
            } label: {
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

            Spacer()
        }
        .padding()
    }

    // MARK: - Login Logic

    private func login() {
        guard !email.isEmpty, !password.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await APIClient.shared.login(
                    email: email,
                    password: password
                )

                // ✅ Switch app to logged-in state
                appState.isLoggedIn = true

            } catch {
                errorMessage = "Invalid email or password"
            }

            isLoading = false
        }
    }
}
