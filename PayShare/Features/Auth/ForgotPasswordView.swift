import SwiftUI

struct ForgotPasswordView: View {

    @State private var email = ""
    @State private var resetToken = ""
    @State private var message: String?
    @State private var isLoading = false
    @State private var navigateToReset = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                Text("Forgot Password")
                    .font(.largeTitle.bold())

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                Button {
                    Task { await sendReset() }
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Send Reset Link")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(email.isEmpty || isLoading)

                if let message {
                    Text(message)
                        .foregroundColor(.green)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $navigateToReset) {
                ResetPasswordView(token: resetToken)
            }
        }
    }

    private func sendReset() async {
        isLoading = true
        message = nil

        do {
            let token = try await APIClient.shared.forgotPassword(email: email)

            if token.isEmpty {
                message = "Email not found."
            } else {
                resetToken = token
                navigateToReset = true
            }

        } catch {
            message = "Something went wrong."
        }

        isLoading = false
    }
}
