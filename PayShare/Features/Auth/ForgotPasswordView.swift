import SwiftUI

struct ForgotPasswordView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var message: String?

    var body: some View {
        VStack(spacing: 20) {

            Text("Reset Password")
                .font(.largeTitle.bold())

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            Button("Send Reset Link") {
                message = "If this email exists, a reset link was sent."
            }
            .buttonStyle(.borderedProminent)

            if let message {
                Text(message)
                    .foregroundColor(.green)
                    .font(.footnote)
            }

            Spacer()
        }
        .padding()
    }
}
