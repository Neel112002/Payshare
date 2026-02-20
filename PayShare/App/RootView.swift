import SwiftUI

struct RootView: View {

    @StateObject private var appState = AppState()
    @StateObject private var activityStore = ActivityStore()
    @StateObject private var profileStore: ProfileStore

    init() {
        let appState = AppState()
        _appState = StateObject(wrappedValue: appState)
        _activityStore = StateObject(wrappedValue: ActivityStore())
        _profileStore = StateObject(wrappedValue: ProfileStore(appState: appState))
    }

    var body: some View {
        ZStack {
            if appState.isLoggedIn {
                mainTabs
            } else {
                LoginView()
            }
        }
        .environmentObject(appState)
        .environmentObject(activityStore)
        .environmentObject(profileStore)
    }

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
