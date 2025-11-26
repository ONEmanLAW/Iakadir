import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var chatStore = ChatStore()
    @State private var hasStartedAuth = false

    var body: some View {
        NavigationStack {
            if let user = authViewModel.currentUser {
                HomeView(username: user.username)
                    .environmentObject(authViewModel)
                    .environmentObject(chatStore)
            } else if hasStartedAuth {
                LoginView(onBack: {
                    hasStartedAuth = false
                })
                .environmentObject(authViewModel)
            } else {
                OnboardingView(onStart: {
                    hasStartedAuth = true
                })
                .environmentObject(authViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
