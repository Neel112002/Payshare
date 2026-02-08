import SwiftUI

struct RootView: View {

    // ✅ Global stores created ONCE
    @StateObject private var activityStore = ActivityStore()
    @StateObject private var profileStore = ProfileStore()
    @StateObject private var expenseStore = ExpenseStore()

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
        // ✅ Inject stores into entire app hierarchy
        .environmentObject(activityStore)
        .environmentObject(profileStore)
        .environmentObject(expenseStore)
    }
}
