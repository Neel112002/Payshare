import SwiftUI

struct LoginView: View {

    @EnvironmentObject private var appState: AppState

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showPassword = false

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

                    // App Logo Area
                    VStack(spacing: 8) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.blue)

                        Text("PayShare")
                            .font(.largeTitle.bold())
                    }

                    VStack(spacing: 16) {

                        // Email Field
                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5)

                        // Password Field
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

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }

                    // Login Button
                    Button(action: login) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Login")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .shadow(color: .blue.opacity(0.3), radius: 10)
                    .disabled(email.isEmpty || password.isEmpty || isLoading)

                    // Links
                    VStack(spacing: 8) {
                        NavigationLink("Forgot Password?", destination: ForgotPasswordView())
                            .font(.footnote)

                        NavigationLink("Create Account", destination: RegisterView())
                            .font(.footnote.bold())
                    }
                    .foregroundStyle(.blue)
                }
                .padding(32)
                .background(Color.white.opacity(0.8))
                .cornerRadius(24)
                .padding()

                Spacer()
            }
        }
    }

    private func login() {
        guard !email.isEmpty, !password.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await APIClient.shared.login(email: email, password: password)
                await MainActor.run {
                    appState.isLoggedIn = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Invalid email or password"
                }
            }

            await MainActor.run {
                isLoading = false
            }
        }
    }
}
