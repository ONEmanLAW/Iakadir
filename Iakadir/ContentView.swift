import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var chatStore: ChatStore
    @State private var hasStartedAuth = false

    var body: some View {
        NavigationStack {
            if let user = authViewModel.currentUser {
                HomeView(username: user.username)
            } else if hasStartedAuth {
                LoginView(onBack: {
                    hasStartedAuth = false
                })
            } else {
                OnboardingView(onStart: {
                    hasStartedAuth = true
                })
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(ChatStore())
}
