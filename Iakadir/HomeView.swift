//
//  HomeView.swift
//  Iakadir
//
//  Created by digital on 19/11/2025.
//

import SwiftUI

struct HomeView: View {
    let username: String
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var chatStore: ChatStore
    @EnvironmentObject var notificationManager: NotificationManager

    @State private var showMenu = false
    @State private var selectedConversationID: UUID?
    @State private var showConversationOptions = false
    @State private var showRenameSheet = false
    @State private var renameText: String = ""

    @State private var showPaywallFromNotification = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {

                header
                heroSection

                historyHeader
                historyList

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.top, 24)
            .padding(.bottom, 2)
        }
        .sheet(isPresented: $showMenu) {
            menuSheet
        }
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("Options de la conversation",
                            isPresented: $showConversationOptions,
                            titleVisibility: .visible) {
            Button("Renommer") { prepareRename() }
            Button("Supprimer", role: .destructive) { deleteSelectedConversation() }
            Button("Annuler", role: .cancel) {}
        }
        .sheet(isPresented: $showRenameSheet) {
            renameSheet
        }
        .navigationDestination(isPresented: $showPaywallFromNotification) {
            PaywallView()
        }
        .onAppear {
            if notificationManager.navigateToPaywallFromNotification {
                showPaywallFromNotification = true
                notificationManager.navigateToPaywallFromNotification = false
            }
        }
        .onChange(of: notificationManager.navigateToPaywallFromNotification) { _, newValue in
            if newValue {
                showPaywallFromNotification = true
                notificationManager.navigateToPaywallFromNotification = false
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
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

            NavigationLink {
                PaywallView()
            } label: {
                HStack(spacing: 6) {
                    Text("PRO")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primaryGreen)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(red: 18/255, green: 18/255, blue: 36/255))
                        .overlay(
                            Capsule()
                                .stroke(Color.primaryGreen, lineWidth: 1.5)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        let smallHeight: CGFloat = 110
        let verticalSpacing: CGFloat = 12
        let bigHeight: CGFloat = smallHeight * 2 + verticalSpacing   // 232

        return VStack(alignment: .leading, spacing: 60) {
            Text("Qu’est-ce que tu\nveux faire ?")
                .foregroundColor(.white)
                .font(.system(size: 28, weight: .semibold))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)

            HStack(alignment: .top, spacing: 8) {

                NavigationLink {
                    ChatView(mode: .summarizeAudio, conversationID: nil)
                } label: {
                    ActionCard(
                        title: "Résumer\nun son",
                        iconName: "ear.badge.waveform",
                        background: Color.primaryGreen,
                        height: bigHeight,
                        titleFontSize: 24
                    )
                }
                .buttonStyle(.plain)

                VStack(spacing: verticalSpacing) {

                    NavigationLink {
                        ChatView(mode: .assistant, conversationID: nil)
                    } label: {
                        ActionCard(
                            title: "Parler à l’IA",
                            iconName: "text.bubble",
                            background: Color(red: 0.80, green: 0.75, blue: 1.0),
                            height: smallHeight,
                            titleFontSize: 18
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        ChatView(mode: .generateImage, conversationID: nil)
                    } label: {
                        ActionCard(
                            title: "Générer une image",
                            iconName: "photo.on.rectangle",
                            background: Color.lightPink,
                            height: smallHeight,
                            titleFontSize: 18
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Historique

    private var historyHeader: some View {
        HStack {
            Text("Historique")
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .semibold))
            Spacer()
            NavigationLink {
                HistoryView()
            } label: {
                Text("Voir tout")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 14, weight: .medium))
            }
        }
    }

    // helper pour icône + couleur selon le mode
    private func iconConfig(for mode: ChatMode) -> (Color, String) {
        switch mode {
        case .assistant:
            return (Color.primaryPurple, "text.bubble")
        case .summarizeAudio:
            return (Color.primaryGreen, "ear.badge.waveform")
        case .generateImage:
            return (Color.lightPink, "photo.on.rectangle")
        }
    }

    @ViewBuilder
    private var historyList: some View {
        let sorted = chatStore.conversations.sorted { $0.updatedAt > $1.updatedAt }
        let topThree = Array(sorted.prefix(3))

        VStack(spacing: 12) {
            if topThree.isEmpty {
                Text("Aucune conversation pour l’instant.")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
            } else {
                ForEach(topThree) { conv in
                    let (bgColor, iconName) = iconConfig(for: conv.mode)

                    NavigationLink {
                        ChatView(mode: conv.mode, conversationID: conv.id)
                    } label: {
                        HistoryRow(
                            iconBackground: bgColor,
                            iconName: iconName,
                            text: displayText(for: conv),
                            onMoreTapped: {
                                selectedConversationID = conv.id
                                showConversationOptions = true
                            }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func displayText(for conv: Conversation) -> String {
        if !conv.title.isEmpty {
            return conv.title
        } else if !conv.lastMessagePreview.isEmpty {
            return conv.lastMessagePreview
        } else {
            return "Nouvelle conversation"
        }
    }

    // MARK: - Menu / rename (inchangé)

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

    private func prepareRename() {
        guard let id = selectedConversationID,
              let conv = chatStore.conversations.first(where: { $0.id == id }) else { return }

        if !conv.title.isEmpty {
            renameText = conv.title
        } else if !conv.lastMessagePreview.isEmpty {
            renameText = conv.lastMessagePreview
        } else {
            renameText = ""
        }
        showRenameSheet = true
    }

    private func deleteSelectedConversation() {
        guard let id = selectedConversationID else { return }
        chatStore.deleteConversation(id: id)
        selectedConversationID = nil
    }

    private var renameSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Renommer la conversation")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.top, 12)

                TextField("Titre de la conversation", text: $renameText)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(white: 0.15))
                    )
                    .foregroundColor(.white)

                Spacer()

                Button {
                    guard let id = selectedConversationID else {
                        showRenameSheet = false
                        return
                    }
                    chatStore.renameConversation(id: id, newTitle: renameText)
                    showRenameSheet = false
                } label: {
                    Text("Enregistrer")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.primaryGreen)
                        )
                }

                Button(role: .cancel) {
                    showRenameSheet = false
                } label: {
                    Text("Annuler")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                }
            }
            .padding(20)
            .background(Color.black.ignoresSafeArea())
        }
        .presentationDetents([.height(260)])
    }
}

// MARK: - Sous-vues

struct ActionCard: View {
    let title: String
    let iconName: String
    let background: Color
    let height: CGFloat
    var titleFontSize: CGFloat = 18

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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

            Spacer()

            Text(title)
                .foregroundColor(.black)
                .font(.system(size: titleFontSize, weight: .semibold))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(background)
        )
    }
}

struct HistoryRow: View {
    let iconBackground: Color
    let iconName: String
    let text: String
    let onMoreTapped: () -> Void

    var body: some View {
        HStack(spacing: 10) {
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
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Button(action: onMoreTapped) {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(6)
                    .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.06))
        )
    }
}

#Preview {
    NavigationStack {
        HomeView(username: "Ethan")
            .environmentObject(AuthViewModel())
            .environmentObject(ChatStore(userID: "preview-user"))
            .environmentObject(NotificationManager.shared)
    }
}
