import SwiftUI

struct RootView: View {

    @StateObject private var activityStore = ActivityStore()
    @StateObject private var profileStore = ProfileStore()

    var body: some View {
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
        .environmentObject(activityStore)
        .environmentObject(profileStore)
    }
}
