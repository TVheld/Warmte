import SwiftUI

@main
struct WarmteverliesDashboardApp: App {
    @StateObject private var persistence = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                DashboardView()
            }
            .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
