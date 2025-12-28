import Foundation

struct Conversation: Identifiable, Codable {
    var id: UUID
    var title: String
    var lastMessagePreview: String
    var updatedAt: Date
    var messages: [ChatMessage]
    var mode: ChatMode

    enum CodingKeys: String, CodingKey {
        case id, title, lastMessagePreview, updatedAt, messages, mode
    }

    init(
        id: UUID = UUID(),
        title: String = "",
        lastMessagePreview: String = "",
        updatedAt: Date = Date(),
        messages: [ChatMessage] = [],
        mode: ChatMode = .assistant
    ) {
        self.id = id
        self.title = title
        self.lastMessagePreview = lastMessagePreview
        self.updatedAt = updatedAt
        self.messages = messages
        self.mode = mode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        lastMessagePreview = try container.decode(String.self, forKey: .lastMessagePreview)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        messages = try container.decode([ChatMessage].self, forKey: .messages)
        mode = try container.decodeIfPresent(ChatMode.self, forKey: .mode) ?? .assistant
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(lastMessagePreview, forKey: .lastMessagePreview)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(messages, forKey: .messages)
        try container.encode(mode, forKey: .mode)
    }
}

final class ChatStore: ObservableObject {
    @Published var conversations: [Conversation] = []

    private let storageKeyBase = "chat_conversations_v1"
    private var currentUserID: String?

    private var storageKey: String {
        if let id = currentUserID, !id.isEmpty {
            return "\(storageKeyBase)_user_\(id)"
        } else {
            return "\(storageKeyBase)_guest"
        }
    }

    init(userID: String? = nil) {
        self.currentUserID = userID
        load()
    }

    func setUserID(_ id: String?) {
        if id == currentUserID { return }
        currentUserID = id
        load()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            conversations = []
            return
        }
        do {
            let decoded = try JSONDecoder().decode([Conversation].self, from: data)
            conversations = decoded
        } catch {
            print("Erreur decode conversations:", error)
            conversations = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(conversations)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Erreur encode conversations:", error)
        }
    }

    func createConversation(mode: ChatMode) -> Conversation {
        let conversation = Conversation(
            id: UUID(),
            title: "",
            lastMessagePreview: "",
            updatedAt: Date(),
            messages: [],
            mode: mode
        )
        conversations.insert(conversation, at: 0)
        save()
        return conversation
    }

    func conversation(with id: UUID) -> Conversation? {
        conversations.first { $0.id == id }
    }

    // ✅ UPDATED: preview + pas de placeholders moches
    func updateConversation(id: UUID, messages: [ChatMessage]) {
        guard let index = conversations.firstIndex(where: { $0.id == id }) else { return }

        var conv = conversations[index]
        conv.messages = messages

        let candidates = messages.filter { msg in
            msg.text != "…" && msg.text != "Génération en cours…"
        }

        if conv.mode == .generateImage {
            if let lastUser = candidates.last(where: { $0.isUser }) {
                conv.lastMessagePreview = lastUser.text
            } else if let last = candidates.last {
                conv.lastMessagePreview = last.text
            } else {
                conv.lastMessagePreview = ""
            }
        } else {
            if let last = candidates.last {
                conv.lastMessagePreview = last.text
            } else {
                conv.lastMessagePreview = ""
            }
        }

        conv.updatedAt = Date()
        conversations[index] = conv
        save()
    }

    func renameConversation(id: UUID, newTitle: String) {
        guard let index = conversations.firstIndex(where: { $0.id == id }) else { return }
        conversations[index].title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        save()
    }

    func deleteConversation(id: UUID) {
        conversations.removeAll { $0.id == id }
        save()
    }
}
