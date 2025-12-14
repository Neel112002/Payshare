import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState

    @State private var email = ""
    @State private var password = ""
    @State private var errorText: String?

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 18) {
                VStack(spacing: 8) {
                    Text("PayShare")
                        .font(.system(size: 34, weight: .bold))
                    Text("Split bills, settle fast.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }

                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding(14)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    SecureField("Password", text: $password)
                        .padding(14)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                if let errorText {
                    Text(errorText)
                        .foregroundStyle(.red)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    if email.isEmpty || password.isEmpty {
                        errorText = "Please enter email and password."
                        return
                    }
                    errorText = nil
                    appState.isLoggedIn = true
                } label: {
                    Text("Login")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Text("No account yet? We’ll add signup later.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(22)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .padding(.horizontal, 20)

            Spacer()
        }
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.20), .purple.opacity(0.15), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}
