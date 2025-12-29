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
        
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
               
                notificationManager.cancelBackgroundProReminders()

            case .background:
                
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
