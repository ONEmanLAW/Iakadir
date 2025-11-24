import SwiftUI

struct HomeView: View {
    let username: String
    @EnvironmentObject var auth: AuthViewModel
    @State private var showMenu = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {

                // HEADER
                header

                // BLOC "Qu’est-ce que tu veux faire ?"
                heroSection

                // SECTION HISTORIQUE
                historyHeader

                historyList

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)
        }
        .sheet(isPresented: $showMenu) {
            menuSheet
        }
        .toolbar(.hidden, for: .navigationBar)   // cache la barre grise
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button {
                showMenu = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 40, height: 40)

                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
            }

            Spacer()

            HStack(spacing: 4) {
                Text("Hello, \(username)")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                Text("👋")
            }

            Spacer()

            HStack(spacing: 6) {
                Text("PRO")
                    .font(.system(size: 13, weight: .semibold))
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .bold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .stroke(Color.primaryGreen, lineWidth: 1.5)
                    .background(
                        Capsule().fill(Color.white.opacity(0.05))
                    )
            )
            .foregroundColor(.white)
        }
    }

    // MARK: - Hero section

    private var heroSection: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 32)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.primaryGreen.opacity(0.45),
                            Color.black
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 24) {
                Text("Qu’est-ce que tu\nveux faire ?")
                    .foregroundColor(.white)
                    .font(.system(size: 28, weight: .semibold))

                VStack(spacing: 16) {
                    // grande carte
                    ActionCard(
                        title: "Résumer\nun son",
                        iconName: "ear.badge.waveform",
                        background: Color.primaryGreen,
                        isLarge: true
                    )

                    // deux cartes plus petites
                    HStack(spacing: 16) {

                        // 👉 Parler à l’IA : navigation vers ChatView
                        NavigationLink {
                            ChatView()
                        } label: {
                            ActionCard(
                                title: "Parler à l’IA",
                                iconName: "text.bubble",
                                background: Color(red: 0.80, green: 0.75, blue: 1.0),
                                isLarge: false
                            )
                        }
                        .buttonStyle(.plain)

                        ActionCard(
                            title: "Générer une image",
                            iconName: "photo.on.rectangle",
                            background: Color.lightPink,
                            isLarge: false
                        )
                    }
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Historique

    private var historyHeader: some View {
        HStack {
            Text("Historique")
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .semibold))
            Spacer()
            Button {
                // plus tard : voir tout
            } label: {
                Text("Voir tout")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 14, weight: .medium))
            }
        }
    }

    private var historyList: some View {
        VStack(spacing: 12) {
            HistoryRow(
                iconBackground: Color.primaryGreen,
                iconName: "ear.badge.waveform",
                text: "Swift est un langage de programmation..."
            )

            HistoryRow(
                iconBackground: Color(red: 0.80, green: 0.75, blue: 1.0),
                iconName: "text.bubble",
                text: "Dis-moi qui est Elvia Front, s’il te plaît..."
            )

            HistoryRow(
                iconBackground: Color.lightPink,
                iconName: "photo.on.rectangle",
                text: "Un sanglier qui danse avec son père..."
            )
        }
    }

    // MARK: - Menu déconnexion

    private var menuSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Menu")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.top, 16)

                Text("Connecté en tant que \(username)")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))

                Button {
                    Task { await auth.logout() }
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Se déconnecter")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.red.opacity(0.1))
                    )
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding(20)
        }
        .presentationDetents([.height(220)])
    }
}

// MARK: - Sous-vues réutilisables

struct ActionCard: View {
    let title: String
    let iconName: String
    let background: Color
    let isLarge: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 28)
                .fill(background)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.12))
                            .frame(width: 36, height: 36)

                        Image(systemName: iconName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                }

                Text(title)
                    .foregroundColor(.black)
                    .font(.system(size: 18, weight: .semibold))
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: isLarge ? 180 : 120)
    }
}

struct HistoryRow: View {
    let iconBackground: Color
    let iconName: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconBackground)
                    .frame(width: 40, height: 40)

                Image(systemName: iconName)
                    .foregroundColor(.black)
                    .font(.system(size: 18, weight: .medium))
            }

            Text(text)
                .foregroundColor(.white)
                .font(.system(size: 15))
                .lineLimit(1)

            Spacer()

            Image(systemName: "ellipsis")
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white.opacity(0.06))
        )
    }
}

#Preview {
    HomeView(username: "Ethan")
        .environmentObject(AuthViewModel())
}
