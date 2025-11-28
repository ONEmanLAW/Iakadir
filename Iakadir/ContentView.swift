import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var chatStore: ChatStore
    @State private var hasStartedAuth = false

    // 🔔 Modal déclenché par le shake
    @State private var showShakeModal = false

    var body: some View {
        ZStack {
            // Navigation principale
            NavigationStack {
                if let user = authViewModel.currentUser {
                    // Utilisateur connecté → Home
                    HomeView(username: user.username)
                } else if hasStartedAuth {
                    // L'utilisateur a cliqué sur "Commencer" → écran de login
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

            // 👉 Détection du shake uniquement quand on est connecté
            if authViewModel.currentUser != nil {
                ShakeDetector {
                    // Vibration forte pour confirmer que le shake est détecté
                    HapticsManager.shared.strongTap()

                    // Affichage du modal
                    showShakeModal = true
                }
                .allowsHitTesting(false) // ne bloque pas les interactions avec l’UI
            }
        }
        // Alerte quand on secoue le téléphone
        .alert(
            "Vous avez repéré un problème ?",
            isPresented: $showShakeModal
        ) {
            Button("OK", role: .cancel) {
                // plus tard : ouvrir un formulaire, envoyer un log, etc.
            }
        } message: {
            Text("Dites-nous tout…")
        }
        // iOS 17 : onChange (old,new) + initial
        .onChange(of: authViewModel.currentUser?.id, initial: true) { _, newID in
            syncChatStore(with: newID)
        }
    }

    /// Sync le ChatStore avec l'utilisateur courant
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
