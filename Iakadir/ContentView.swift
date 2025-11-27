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
                // Premier lancement → onboarding
                OnboardingView(onStart: {
                    hasStartedAuth = true
                })
            }
        }
        
        .onChange(of: authViewModel.currentUser?.id, initial: true) { _, newID in
            syncChatStore(with: newID)
        }
    }

    private func syncChatStore(with id: UUID?) {
        if let id = id {
            chatStore.setUserID(id.uuidString)
        } else {
            chatStore.setUserID(nil)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(ChatStore())
}
