//
//  HistoryView.swift
//  Iakadir
//
//  Created by digital on 25/11/2025.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var chatStore: ChatStore

    @State private var selectedConversationID: UUID?
    @State private var showConversationOptions = false
    @State private var showRenameSheet = false
    @State private var renameText: String = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {

                header

                // On calcule la liste triée une seule fois
                let sorted = chatStore.conversations
                    .sorted { $0.updatedAt > $1.updatedAt }

                ScrollView {
                    VStack(spacing: 12) {
                        if sorted.isEmpty {
                            Text("Aucune conversation pour l’instant.")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                        } else {
                            ForEach(sorted) { conv in
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
                    .padding(.top, 8)
                }
                // 🔒 Pas de scroll si aucune conversation
                .scrollDisabled(sorted.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)
            // 🖼 Décor en background, en haut à droite
            .background(
                ZStack(alignment: .topTrailing) {
                    Image("trait2")
                        
                        .scaledToFit()
                        
                        
                        .offset(x: 70, y: -320)
                        .allowsHitTesting(false)
                }
            )
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
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 40, height: 40)

                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
            }

            Spacer()

            Text("Historique")
                .foregroundColor(.white)
                .font(.system(size: 22, weight: .semibold))

            Spacer()

            Color.clear.frame(width: 40, height: 40)
        }
    }

    // MARK: - Icônes selon le mode

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

    private func displayText(for conv: Conversation) -> String {
        if !conv.title.isEmpty {
            return conv.title
        } else if !conv.lastMessagePreview.isEmpty {
            return conv.lastMessagePreview
        } else {
            return "Nouvelle conversation"
        }
    }

    // MARK: - Rename / delete

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

#Preview {
    NavigationStack {
        HistoryView()
            .environmentObject(ChatStore(userID: "preview-user"))
    }
}
