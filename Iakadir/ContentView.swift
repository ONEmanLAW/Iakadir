import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var chatStore: ChatStore
    @EnvironmentObject var notificationManager: NotificationManager

    @State private var hasStartedAuth = false
    @State private var hasShownOnboarding = false

    @State private var showShakeDebugSheet: Bool = false

    var body: some View {
        NavigationStack {
            if !hasShownOnboarding {
                OnboardingView {
                    hasShownOnboarding = true

                    if authViewModel.currentUser != nil {
                        hasStartedAuth = false
                    } else {
                        hasStartedAuth = true
                    }
                }

            } else if let user = authViewModel.currentUser {
                HomeView(username: user.username)

            } else if hasStartedAuth {
                LoginView(onBack: {
                    hasStartedAuth = false
                })

            } else {
                LoginView(onBack: {
                    hasStartedAuth = false
                })
            }
        }
        .overlay(
            ShakeDetector {
                showShakeDebugSheet = true
                print("SHAKE ")
            }
            .allowsHitTesting(false)
        )
        .sheet(isPresented: $showShakeDebugSheet) {
            debugSheet
        }
        .onChange(of: authViewModel.currentUser?.id, initial: true) { _, newID in
            syncChatStore(with: newID)
        }
        .onChange(of: notificationManager.navigateToPaywallFromNotification, initial: true) { _, newValue in
            if newValue {
                if authViewModel.currentUser == nil {
                    hasStartedAuth = true
                }
            }
        }
        .task {
            await authViewModel.restoreSessionIfNeeded()
        }
    }

    private var debugSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text("Debug")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)

        
                Button {
                    reportProblem()
                    showShakeDebugSheet = false
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.bubble")
                        Text("Signaler un problème")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white.opacity(0.10))
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }

                Button {
                    
                    hasShownOnboarding = false
                    showShakeDebugSheet = false
                } label: {
                    Text("Rejouer l’onboarding")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.primaryGreen)
                        .foregroundColor(.black)
                        .cornerRadius(14)
                }

                Button(role: .destructive) {

                    chatStore.conversations = []
                    showShakeDebugSheet = false
                } label: {
                    Text("Vider l’historique (debug)")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red.opacity(0.15))
                        .foregroundColor(.red)
                        .cornerRadius(14)
                }

                Spacer()
            }
            .padding(20)
            .background(Color.black.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { showShakeDebugSheet = false }
                        .foregroundColor(.white)
                }
            }
        }
        .presentationDetents([.height(320)])
    }


    private func reportProblem() {
        let to = "support@iakadir.app"

        let userID = authViewModel.currentUser?.id.uuidString ?? "guest"
        let device = UIDevice.current.model
        let os = UIDevice.current.systemVersion
        let app = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"

        let subject = "Iakadir — Signalement de problème"
        let body =
        """


        ---
        Infos auto :
        - UserID: \(userID)
        - Device: \(device)
        - iOS: \(os)
        - App version: \(app) (\(build))
        """

        let urlString =
        "mailto:\(to)?subject=\(subject.urlQueryEncoded)&body=\(body.urlQueryEncoded)"

        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
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


private extension String {
    var urlQueryEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(ChatStore(userID: "preview-user"))
        .environmentObject(NotificationManager.shared)
}
