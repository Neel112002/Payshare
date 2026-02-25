import SwiftUI

struct ProfileView: View {

    @EnvironmentObject var appState: AppState

    var body: some View {

        ScrollView {
            VStack(spacing: 24) {

                // MARK: - Header

                VStack(spacing: 12) {

                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text(appState.currentUser?.name ?? "User")
                        .font(.title2.bold())

                    Text(appState.currentUser?.email ?? "")
                        .font(.footnote)
                        .foregroundColor(.gray)

                    Button("Edit Profile") {
                        // Future: Navigate to edit profile screen
                    }
                    .font(.footnote)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(20)
                }
                .padding(.top)

                Divider()

                // MARK: - Account Section

                VStack(spacing: 16) {

                    profileRow(icon: "lock.fill", title: "Change Password") {
                        // Future navigation
                    }

                    profileRow(icon: "key.fill", title: "Reset Password") {
                        // Navigate to ForgotPasswordView
                    }

                    profileRow(icon: "trash.fill", title: "Delete Account", color: .red) {
                        // Future delete logic
                    }

                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )

                // MARK: - Logout

                Button {
                    appState.logout()
                } label: {
                    Text("Logout")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.1))
                        )
                }

                Spacer(minLength: 40)

                Text("PayShare v1.0")
                    .font(.caption)
                    .foregroundColor(.gray)

            }
            .padding()
        }
        .navigationTitle("Profile")
    }

    // MARK: - Reusable Row

    private func profileRow(
        icon: String,
        title: String,
        color: Color = .blue,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {
            HStack {

                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)

                Text(title)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
        }
    }
}
