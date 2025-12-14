import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        List {
            Section {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.blue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Neel").font(.headline)
                        Text("neel@example.com")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 6)
            }

            Section("Settings") {
                Label("Currency: INR", systemImage: "indianrupeesign.circle")
                Label("Notifications", systemImage: "bell")
            }

            Section {
                Button(role: .destructive) {
                    appState.isLoggedIn = false
                } label: {
                    Text("Logout")
                }
            }
        }
        .navigationTitle("Profile")
    }
}
