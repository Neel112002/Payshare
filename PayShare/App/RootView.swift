import SwiftUI

struct RootView: View {

    @StateObject private var appState = AppState()

    // Global stores (live for entire app lifetime)
    @StateObject private var activityStore = ActivityStore()
    @StateObject private var profileStore = ProfileStore()

    var body: some View {
        ZStack {
            if appState.isLoggedIn {
                mainTabs
            } else {
                LoginView()
            }
        }
        // ✅ Inject once at the top
        .environmentObject(appState)
        .environmentObject(activityStore)
        .environmentObject(profileStore)

        // 🔑 THIS IS THE IMPORTANT PART
        .task {
            // If token exists, user is already logged in
            if APIClient.shared.authToken != nil {
                appState.isLoggedIn = true
            }
        }
    }

    // MARK: - Main Tabs (Logged In)

    private var mainTabs: some View {
        TabView {

            NavigationStack {
                GroupListView()
            }
            .tabItem {
                Label("Groups", systemImage: "person.3.fill")
            }

            NavigationStack {
                ActivityView()
            }
            .tabItem {
                Label("Activity", systemImage: "clock.arrow.circlepath")
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
    }
}
