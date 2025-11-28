import SwiftUI

@main
struct IakadirApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var chatStore = ChatStore()
    @StateObject var notificationManager = NotificationManager.shared

    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(chatStore)
                .environmentObject(notificationManager)
                .onAppear {
                    notificationManager.requestAuthorization()
                    // debug rapide :
                    // notificationManager.sendDebugNotification()
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                // App au premier plan → on ne veut pas de notifs PRO
                notificationManager.cancelBackgroundProReminders()

            case .background:
                // App en arrière-plan → si pas PRO, on planifie UNE notif
                if !authViewModel.isProUser {
                    let isLoggedIn = (authViewModel.currentUser != nil)
                    let name = authViewModel.currentUser?.username
                    notificationManager.scheduleBackgroundProReminder(
                        isLoggedIn: isLoggedIn,
                        username: name
                    )
                } else {
                    notificationManager.cancelBackgroundProReminders()
                }

            default:
                break
            }
        }
    }
}
