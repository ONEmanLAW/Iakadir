import SwiftUI
import UIKit

enum ImageStyle: String, CaseIterable, Identifiable {
    case surreal = "Irréaliste"
    case realistic = "Réaliste"
    case cinematic = "Cinématique"
    case anime = "Dessin animé"
    case illustration = "Illustration"
    case threeD = "3D"
    case pixel = "Pixel Art"

    var id: String { rawValue }
    var lowercaseLabel: String { rawValue.lowercased() }
}

struct GenerateImageView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var chatStore: ChatStore

    let conversationID: UUID?

    @State private var resolvedConversationID: UUID?
    @State private var messages: [ChatMessage] = []

    @State private var selectedStyle: ImageStyle = .surreal
    @State private var inputText: String = ""
    @State private var isSending: Bool = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                header
                stylePickerRow
                chatContent
                inputBar
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { setupConversation() }
    }

    // MARK: - Setup / Persist

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

        let newConv = chatStore.createConversation(mode: .generateImage)
        resolvedConversationID = newConv.id
        messages = newConv.messages
    }

    private func persistMessages() {
        guard let id = resolvedConversationID else { return }
        chatStore.updateConversation(id: id, messages: messages)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                ZStack {
                    Circle().fill(Color.white.opacity(0.08)).frame(width: 40, height: 40)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
            }

            Spacer()

            Text("Générer une image")
                .foregroundColor(.white)
                .font(.system(size: 17, weight: .semibold))

            Spacer()

            HStack(spacing: 6) {
                Text("GPT-4").font(.system(size: 13, weight: .semibold))
                Image(systemName: "sparkles").font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.primaryGreen))
            .foregroundColor(.black)
        }
        .padding(.top, 8)
    }

    // MARK: - Style Picker

    private var stylePickerRow: some View {
        Menu {
            ForEach(ImageStyle.allCases) { style in
                Button { selectedStyle = style } label: { Text(style.rawValue) }
            }
        } label: {
            HStack {
                Text("Style de l’image générée")
                    .foregroundColor(.white.opacity(0.65))
                    .font(.system(size: 15, weight: .medium))

                Spacer()

                Text(selectedStyle.rawValue)
                    .foregroundColor(Color.primaryGreen)
                    .font(.system(size: 15, weight: .semibold))

                Image(systemName: "chevron.down")
                    .foregroundColor(.white.opacity(0.55))
                    .font(.system(size: 13, weight: .semibold))
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(red: 0.07, green: 0.08, blue: 0.16))
            )
        }
    }

    // MARK: - Chat

    private var chatContent: some View {
        let lastAssistantId = messages.last(where: { !$0.isUser })?.id

        return ScrollView {
            VStack(spacing: 16) {
                if messages.isEmpty {
                    Text("Décris l’image que tu veux générer.")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 15))
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                        .frame(maxWidth: .infinity)
                } else {
                    ForEach(messages) { msg in
                        if !msg.isUser && msg.id == lastAssistantId {
                            VStack(spacing: 0) {
                                assistantBubble(message: msg)

                                HStack(spacing: 32) {
                                    ActionChip(icon: "arrow.clockwise", title: "Régénérer") {
                                        regenerateLast()
                                    }
                                    ActionChip(icon: "doc.on.doc", title: "Copier") {
                                        UIPasteboard.general.string = msg.text
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
                            if msg.isUser {
                                MessageBubble(text: msg.text, isUser: true)
                            } else {
                                assistantBubble(message: msg)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.top, 6)
        }
    }

    private func assistantBubble(message: ChatMessage) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {

                if message.kind == .imageResult {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.black.opacity(0.18))

                        VStack(spacing: 10) {
                            Image(systemName: "photo")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.35))

                            if message.text == "Génération en cours…" {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                        }
                    }
                    .frame(height: 220)
                }

                Text(message.text)
                    .foregroundColor(.white)
                    .font(.system(size: 15))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(red: 0.13, green: 0.13, blue: 0.15))
            )

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }

    // MARK: - Input

    private var inputBar: some View {
        HStack {
            TextField("Écris une demande ici", text: $inputText)
                .foregroundColor(.white)
                .font(.system(size: 15))
                .textInputAutocapitalization(.sentences)
                .disableAutocorrection(true)
                .padding(.leading, 20)

            Spacer(minLength: 8)

            Button {
                let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                sendPrompt(trimmed)
                inputText = ""
            } label: {
                ZStack {
                    Circle().fill(Color.primaryGreen).frame(width: 42, height: 42)
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .semibold))
                }
                .padding(.trailing, 6)
            }
            .disabled(isSending || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity((isSending || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 0.5 : 1)
        }
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color(red: 0.07, green: 0.08, blue: 0.16))
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }

    // MARK: - Quota messages

    private func quotaMessageForSubmit(style: ImageStyle) -> String {
        "Votre image \(style.lowercaseLabel) a bien été prise en compte par GPT, mais il n’y a plus assez de crédit sur le compte API, flemme de payer hehe."
    }

    private func quotaMessageForRegenerate(style: ImageStyle) -> String {
        "Votre image \(style.lowercaseLabel) a bien été régénérée et prise en compte par GPT, mais il n’y a plus assez de crédit sur le compte API, flemme de payer hehe."
    }

    // MARK: - Send / Regenerate (ajoute, ne remplace rien)

    private func sendPrompt(_ prompt: String) {
        guard !isSending else { return }
        isSending = true

        let frozenStyle = selectedStyle

        messages.append(ChatMessage(text: prompt, isUser: true, kind: .text))

        let placeholderID = UUID()
        messages.append(
            ChatMessage(
                id: placeholderID,
                text: "Génération en cours…",
                isUser: false,
                kind: .imageResult,
                imageStyle: frozenStyle.rawValue
            )
        )
        persistMessages()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let idx = messages.firstIndex(where: { $0.id == placeholderID }) {
                messages[idx].text = quotaMessageForSubmit(style: frozenStyle)
            }
            persistMessages()
            isSending = false
        }
    }

    private func regenerateLast() {
        guard !isSending else { return }
        guard messages.contains(where: { $0.isUser }) else { return }

        isSending = true
        let frozenStyle = selectedStyle

        let placeholderID = UUID()
        messages.append(
            ChatMessage(
                id: placeholderID,
                text: "Génération en cours…",
                isUser: false,
                kind: .imageResult,
                imageStyle: frozenStyle.rawValue
            )
        )
        persistMessages()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let idx = messages.firstIndex(where: { $0.id == placeholderID }) {
                messages[idx].text = quotaMessageForRegenerate(style: frozenStyle)
            }
            persistMessages()
            isSending = false
        }
    }
}

#Preview {
    NavigationStack {
        GenerateImageView(conversationID: nil)
            .environmentObject(ChatStore(userID: "preview-user"))
    }
}
