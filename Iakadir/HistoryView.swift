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

            VStack(spacing: 16) {

                header

                ScrollView {
                    VStack(spacing: 12) {
                        let sorted = chatStore.conversations
                            .sorted { $0.updatedAt > $1.updatedAt }

                        if sorted.isEmpty {
                            Text("Aucune conversation pour l’instant.")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.system(size: 14))
                                .padding(.top, 24)
                        } else {
                            ForEach(sorted) { conv in
                                NavigationLink {
                                    ChatView(conversationID: conv.id)
                                } label: {
                                    HistoryRow(
                                        iconBackground: Color.primaryPurple,
                                        iconName: "text.bubble",
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

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 16)
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

    // MARK: - Header

    private var header: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.black)
                .overlay(
                    Image("splashBackground")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.25)
                        .clipped()
                )
                .frame(height: 140)

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
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 8)
    }

    // MARK: - Helpers

    private func displayText(for conv: Conversation) -> String {
        if !conv.title.isEmpty {
            return conv.title
        } else if !conv.lastMessagePreview.isEmpty {
            return conv.lastMessagePreview
        } else {
            return "Nouvelle conversation"
        }
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

#Preview {
    NavigationStack {
        HistoryView()
            .environmentObject(ChatStore())
    }
}
