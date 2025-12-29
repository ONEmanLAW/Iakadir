import SwiftUI
import UIKit


enum ChatMode: String, Codable {
    case assistant
    case summarizeAudio
    case generateImage

    var title: String {
        switch self {
        case .assistant: return "Parler à l’IA"
        case .summarizeAudio: return "Résumer un son"
        case .generateImage: return "Générer une image"
        }
    }

    var placeholder: String {
        switch self {
        case .assistant: return "Écris une demande ici"
        case .summarizeAudio: return "Décris ton audio ou colle un lien ici"
        case .generateImage: return "Décris l’image que tu veux créer"
        }
    }

    var chipLabel: String { "GPT-4" }
}


enum ChatMessageKind: String, Codable {
    case text
    case imageResult
}

struct ChatMessage: Identifiable, Codable {
    var id: UUID = UUID()
    var text: String
    let isUser: Bool

    // NEW
    var kind: ChatMessageKind = .text
    var imageStyle: String? = nil
    var imageURL: String? = nil

    enum CodingKeys: String, CodingKey {
        case id, text, isUser, kind, imageStyle, imageURL
    }

    init(
        id: UUID = UUID(),
        text: String,
        isUser: Bool,
        kind: ChatMessageKind = .text,
        imageStyle: String? = nil,
        imageURL: String? = nil
    ) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.kind = kind
        self.imageStyle = imageStyle
        self.imageURL = imageURL
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        text = try c.decode(String.self, forKey: .text)
        isUser = try c.decode(Bool.self, forKey: .isUser)
        kind = try c.decodeIfPresent(ChatMessageKind.self, forKey: .kind) ?? .text
        imageStyle = try c.decodeIfPresent(String.self, forKey: .imageStyle)
        imageURL = try c.decodeIfPresent(String.self, forKey: .imageURL)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(text, forKey: .text)
        try c.encode(isUser, forKey: .isUser)
        try c.encode(kind, forKey: .kind)
        try c.encodeIfPresent(imageStyle, forKey: .imageStyle)
        try c.encodeIfPresent(imageURL, forKey: .imageURL)
    }
}


struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var chatStore: ChatStore

    let conversationID: UUID?

    @State private var messages: [ChatMessage] = []
    @State private var resolvedConversationID: UUID?
    @State private var inputText: String = ""

    @State private var isSending: Bool = false
    private let ai = OpenAIProxyService()

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
        .onAppear { setupConversation() }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
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
            .background(Capsule().fill(Color.primaryGreen))
            .foregroundColor(.black)
        }
        .padding(.top, 8)
    }

    private var chatContent: some View {
        let lastBotId = messages.last(where: { !$0.isUser })?.id

        return ScrollView {
            VStack(spacing: 16) {
                if messages.isEmpty {
                    Text("Pose-moi une question pour commencer.")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 15))
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                        .frame(maxWidth: .infinity)
                } else {
                    ForEach(messages) { message in
                        if !message.isUser && message.id == lastBotId {
                            VStack(spacing: 0) {
                                MessageBubble(text: message.text, isUser: false)

                                HStack(spacing: 32) {
                                    ActionChip(icon: "arrow.clockwise", title: "Régénérer") {
                                        regenerateLastBotMessage()
                                    }
                                    ActionChip(icon: "doc.on.doc", title: "Copier") {
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
                            MessageBubble(text: message.text, isUser: message.isUser)
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

            Button { sendMessage() } label: {
                ZStack {
                    Circle().fill(Color.primaryGreen).frame(width: 42, height: 42)
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .semibold))
                }
                .padding(.trailing, 6)
            }
            .disabled(isSending)
        }
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color(red: 0.07, green: 0.08, blue: 0.16))
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }


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

        let newConv = chatStore.createConversation(mode: .assistant)
        resolvedConversationID = newConv.id
        messages = newConv.messages
    }

    private func persistMessages() {
        guard let id = resolvedConversationID else { return }
        chatStore.updateConversation(id: id, messages: messages)
    }

    private func openAIInput(from messages: [ChatMessage], limit: Int = 20) -> [OpenAIInputMessage] {
        let filtered = messages.filter { !(!$0.isUser && $0.text == "…") }
        let slice = filtered.suffix(limit)
        return slice.map { msg in
            OpenAIInputMessage(role: msg.isUser ? "user" : "assistant", content: msg.text)
        }
    }

    private func instructions() -> String {
        "Tu es un assistant utile, clair et concis."
    }

    private func isQuotaOrBillingError(_ error: Error) -> Bool {
        let desc = (error as NSError).localizedDescription.lowercased()
        return desc.contains("insufficient_quota")
            || desc.contains("exceeded your current quota")
            || desc.contains("quota")
            || desc.contains("billing")
            || desc.contains("plan and billing")
    }

    private func userFriendlyErrorTextForSend(_ error: Error) -> String {
        if isQuotaOrBillingError(error) {
            return "Ton message a bien été pris en compte par ChatGPT, mais il n’y a plus assez de crédit sur le compte API, flemme de payer hehe."
        }
        return "Impossible de contacter ChatGPT pour le moment."
    }

    private func userFriendlyErrorTextForRegenerate(_ error: Error) -> String {
        if isQuotaOrBillingError(error) {
            return "Ton message a bien été régénéré et pris en compte par GPT, mais il n’y a plus assez de crédit sur le compte API, flemme de payer hehe."
        }
        return "Impossible de contacter ChatGPT pour le moment."
    }

    private func sendMessage() {
        Task { await sendMessageAsync() }
    }

    @MainActor
    private func sendMessageAsync() async {
        if isSending { return }

        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isSending = true

        messages.append(ChatMessage(text: trimmed, isUser: true, kind: .text))
        inputText = ""

        let placeholderID = UUID()
        messages.append(ChatMessage(id: placeholderID, text: "…", isUser: false, kind: .text))
        persistMessages()

        do {
            let input = openAIInput(from: messages, limit: 20)
            let reply = try await ai.generateText(input: input, instructions: instructions(), model: "gpt-4.1")
            if let idx = messages.firstIndex(where: { $0.id == placeholderID }) {
                messages[idx].text = reply
            } else {
                messages.append(ChatMessage(text: reply, isUser: false, kind: .text))
            }
            persistMessages()
        } catch {
            let msg = userFriendlyErrorTextForSend(error)
            if let idx = messages.firstIndex(where: { $0.id == placeholderID }) {
                messages[idx].text = msg
            } else {
                messages.append(ChatMessage(text: msg, isUser: false, kind: .text))
            }
            persistMessages()
        }

        isSending = false
    }

    private func regenerateLastBotMessage() {
        Task { await regenerateAsync() }
    }

    @MainActor
    private func regenerateAsync() async {
        if isSending { return }
        guard let lastBotIndex = messages.lastIndex(where: { !$0.isUser }) else { return }

        isSending = true
        messages.remove(at: lastBotIndex)

        let placeholderID = UUID()
        messages.append(ChatMessage(id: placeholderID, text: "…", isUser: false, kind: .text))
        persistMessages()

        do {
            let input = openAIInput(from: messages, limit: 20)
            let reply = try await ai.generateText(input: input, instructions: instructions(), model: "gpt-4.1")
            if let idx = messages.firstIndex(where: { $0.id == placeholderID }) {
                messages[idx].text = reply
            } else {
                messages.append(ChatMessage(text: reply, isUser: false, kind: .text))
            }
            persistMessages()
        } catch {
            let msg = userFriendlyErrorTextForRegenerate(error)
            if let idx = messages.firstIndex(where: { $0.id == placeholderID }) {
                messages[idx].text = msg
            }
            persistMessages()
        }

        isSending = false
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
