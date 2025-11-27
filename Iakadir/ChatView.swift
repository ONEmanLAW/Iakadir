//
//  ChatView.swift
//  Iakadir
//
//  Created by digital on 24/11/2025.
//

import SwiftUI
import UIKit

struct ChatMessage: Identifiable, Codable {
    var id = UUID()
    var text: String
    let isUser: Bool
}

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var chatStore: ChatStore

    let conversationID: UUID?

    @State private var messages: [ChatMessage] = []
    @State private var resolvedConversationID: UUID?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {

                header
                chatContent
                inputBar
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            setupConversation()
        }
    }

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

            Text("Parler à l’IA")
                .foregroundColor(.white)
                .font(.system(size: 17, weight: .semibold))

            Spacer()

            HStack(spacing: 6) {
                Text("GPT-4")
                    .font(.system(size: 13, weight: .semibold))
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.primaryGreen)
            )
            .foregroundColor(.black)
        }
        .padding(.top, 8)
    }


    private var chatContent: some View {
        let lastBotId = messages.last(where: { !$0.isUser })?.id

        return ScrollView {
            VStack(spacing: 16) {

                if messages.isEmpty {
                    VStack(spacing: 12) {
                        Text("Pose-moi une question pour commencer.")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.system(size: 15))
                            .multilineTextAlignment(.center)
                            .padding(.top, 40)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ForEach(messages) { message in
                        if !message.isUser && message.id == lastBotId {
                            VStack(spacing: 0) {
                                MessageBubble(
                                    text: message.text,
                                    isUser: false
                                )

                                HStack(spacing: 32) {
                                    ActionChip(
                                        icon: "arrow.clockwise",
                                        title: "Régénérer"
                                    ) {
                                        regenerateLastBotMessage()
                                    }

                                    ActionChip(
                                        icon: "doc.on.doc",
                                        title: "Copier"
                                    ) {
                                        copyLastBotMessage()
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                                        .fill(Color.black.opacity(0.95))
                                )
                                .padding(.horizontal, 4)
                                .padding(.top, 4)
                            }
                        } else {
                            MessageBubble(
                                text: message.text,
                                isUser: message.isUser
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }


    private var inputBar: some View {
        HStack {
            TextField("Écris une demande ici", text: $inputText)
                .foregroundColor(.white)
                .font(.system(size: 15))
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding(.leading, 20)

            Spacer(minLength: 8)

            Button {
                sendMessage()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.primaryGreen)
                        .frame(width: 42, height: 42)

                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .semibold))
                }
                .padding(.trailing, 6)
            }
        }
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color(red: 0.07, green: 0.08, blue: 0.16))
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }

    @State private var inputText: String = ""


    private func setupConversation() {
        if let id = resolvedConversationID,
           let conv = chatStore.conversation(with: id) {
            messages = conv.messages
            return
        }

        if let passedID = conversationID,
           let conv = chatStore.conversation(with: passedID) {
            resolvedConversationID = conv.id
            messages = conv.messages
            return
        }

        let newConv = chatStore.createConversation()
        resolvedConversationID = newConv.id
        messages = newConv.messages
    }

    private func persistMessages() {
        guard let id = resolvedConversationID else { return }
        chatStore.updateConversation(id: id, messages: messages)
    }

    private func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let userMessage = ChatMessage(text: trimmed, isUser: true)
        messages.append(userMessage)
        inputText = ""

        let botText = "J’ai reçu ton message."
        let botMessage = ChatMessage(text: botText, isUser: false)
        messages.append(botMessage)

        persistMessages()
    }

    private func regenerateLastBotMessage() {
        guard let index = messages.lastIndex(where: { !$0.isUser }) else { return }
        messages[index].text += " (regénéré)"
        persistMessages()
    }

    private func copyLastBotMessage() {
        guard let lastBot = messages.last(where: { !$0.isUser }) else { return }
        UIPasteboard.general.string = lastBot.text
    }
}

struct MessageBubble: View {
    let text: String
    let isUser: Bool

    var body: some View {
        HStack {
            if isUser { Spacer() }

            Text(text)
                .foregroundColor(.white)
                .font(.system(size: 15))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(isUser
                              ? Color(red: 0.06, green: 0.07, blue: 0.20)
                              : Color(red: 0.13, green: 0.13, blue: 0.15))
                )
                .fixedSize(horizontal: false, vertical: true)

            if !isUser { Spacer() }
        }
        .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
        .padding(.horizontal, 4)
    }
}

struct ActionChip: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(Color.primaryGreen)
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(conversationID: nil)
            .environmentObject(ChatStore(userID: "preview-user"))
    }
}

