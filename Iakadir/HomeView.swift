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
    @State private var showMenu = false

    @State private var selectedConversationID: UUID?
    @State private var showConversationOptions = false
    @State private var showRenameSheet = false
    @State private var renameText: String = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {

                header
                heroSection

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
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("Options de la conversation",
                            isPresented: $showConversationOptions,
                            titleVisibility: .visible) {
            Button("Renommer") {
                prepareRename()
            }
            Button("Supprimer", role: .destructive) {
                deleteSelectedConversation()
            }
            Button("Annuler", role: .cancel) {}
        }
        .sheet(isPresented: $showRenameSheet) {
            renameSheet
        }
    }


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
                    ActionCard(
                        title: "Résumer\nun son",
                        iconName: "ear.badge.waveform",
                        background: Color.primaryGreen,
                        isLarge: true
                    )

                    HStack(spacing: 16) {
                        NavigationLink {
                            ChatView(conversationID: nil)
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

    @ViewBuilder
    private var historyList: some View {
        let sorted = chatStore.conversations
            .sorted { $0.updatedAt > $1.updatedAt }

        // max 3 affichées
        let topThree = Array(sorted.prefix(3))

        VStack(spacing: 12) {
            if topThree.isEmpty {
                Text("Aucune conversation pour l’instant.")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
            } else {
                ForEach(topThree) { conv in
                    HistoryRow(
                        iconBackground: Color.primaryGreen,
                        iconName: "text.bubble",
                        text: displayText(for: conv),
                        onMoreTapped: {
                            selectedConversationID = conv.id
                            showConversationOptions = true
                        }
                    )
                    .background(
                        NavigationLink("", destination: ChatView(conversationID: conv.id))
                            .opacity(0)
                    )
                }
            }
        }
        .frame(height: 220, alignment: .top)
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
    let onMoreTapped: () -> Void

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

            Button(action: onMoreTapped) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.white.opacity(0.7))
            }
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
        .environmentObject(ChatStore())
}
