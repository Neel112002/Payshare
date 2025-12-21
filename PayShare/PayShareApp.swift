import SwiftUI
import Combine

@main
struct PayShareApp: App {

    @StateObject private var expenseStore = ExpenseStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(expenseStore)
        }
    }
}
