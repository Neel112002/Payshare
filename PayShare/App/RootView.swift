import SwiftUI

struct RootView: View {

    // ✅ Create the store ONCE at root level
    @StateObject private var activityStore = ActivityStore()

    var body: some View {
        TabView {

            // MARK: - Groups
            NavigationStack {
                GroupListView()
            }
            .tabItem {
                Label("Groups", systemImage: "person.3.fill")
            }

            // MARK: - Activity
            NavigationStack {
                ActivityView()
            }
            .tabItem {
                Label("Activity", systemImage: "clock.arrow.circlepath")
            }

            // MARK: - Profile
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
        // ✅ Inject into entire tab hierarchy
        .environmentObject(activityStore)
    }
}
