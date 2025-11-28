import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var chatStore: ChatStore
    @EnvironmentObject var notificationManager: NotificationManager

    @State private var hasStartedAuth = false
    /// Indique si l’on a déjà “terminé” l’onboarding pour cette ouverture d’app
    @State private var hasShownOnboarding = false

    var body: some View {
        NavigationStack {
            // 1️⃣ Tant que l’onboarding n’a pas été validé → on le montre
            if !hasShownOnboarding {
                OnboardingView {
                    // Quand l’utilisateur clique sur "Commencer"
                    hasShownOnboarding = true

                    if authViewModel.currentUser != nil {
                        // Déjà connecté → on ira direct sur Home
                        hasStartedAuth = false
                    } else {
                        // Pas connecté → on lance le flux Login
                        hasStartedAuth = true
                    }
                }

            // 2️⃣ Onboarding terminé + user connecté → Home
            } else if let user = authViewModel.currentUser {
                HomeView(username: user.username)

            // 3️⃣ Onboarding terminé + pas connecté + flux auth commencé → Login
            } else if hasStartedAuth {
                LoginView(onBack: {
                    hasStartedAuth = false
                    // Si tu veux revenir à l’onboarding en appuyant sur “back” :
                    // hasShownOnboarding = false
                })

            // 4️⃣ Cas de secours: pas d’onboarding + pas de user → Login
            } else {
                LoginView(onBack: {
                    hasStartedAuth = false
                })
            }
        }
        // 🔁 Sync du ChatStore selon l’utilisateur
        .onChange(of: authViewModel.currentUser?.id, initial: true) { _, newID in
            syncChatStore(with: newID)
        }
        // 🔁 Tap sur notif PRO alors qu’on n’est PAS connecté → on prépare le flux auth
        .onChange(of: notificationManager.navigateToPaywallFromNotification, initial: true) { _, newValue in
            if newValue {
                if authViewModel.currentUser == nil {
                    // On veut que l’utilisateur puisse se connecter / s’inscrire
                    hasStartedAuth = true
                    // On laisse hasShownOnboarding à false pour qu’il voie quand même la splash
                }
            }
        }
        // 🔁 Restaure la session Supabase au lancement (mais n’empêche plus l’onboarding)
        .task {
            await authViewModel.restoreSessionIfNeeded()
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
        .environmentObject(ChatStore(userID: "preview-user"))
        .environmentObject(NotificationManager.shared)
}
