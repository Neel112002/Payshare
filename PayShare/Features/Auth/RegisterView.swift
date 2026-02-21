import SwiftUI

struct RegisterView: View {

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {

            Text("Create Account")
                .font(.largeTitle.bold())

            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Button {
                Task {
                    await register()
                }
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
    }

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
