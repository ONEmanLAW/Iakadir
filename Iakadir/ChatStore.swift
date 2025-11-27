//
//  ChatStore.swift
//  Iakadir
//
//  Created by digital on 24/11/2025.
//

import Foundation

struct Conversation: Identifiable, Codable {
    var id: UUID
    var title: String           // titre custom (peut être vide)
    var lastMessagePreview: String
    var updatedAt: Date
    var messages: [ChatMessage]
}

final class ChatStore: ObservableObject {
    @Published var conversations: [Conversation] = []

    private let storageKeyBase = "chat_conversations_v1"
    private var currentUserID: String?

    // Clé calculée en fonction de l’utilisateur
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

    /// À appeler quand l’utilisateur se connecte / se déconnecte
    func setUserID(_ id: String?) {
        // si c’est le même user, on ne recharge pas pour rien
        if id == currentUserID { return }
        currentUserID = id
        load()
    }

    // Charger depuis UserDefaults pour CE user
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

    // Sauvegarder dans UserDefaults pour CE user
    private func save() {
        do {
            let data = try JSONEncoder().encode(conversations)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Erreur encode conversations:", error)
        }
    }

    func createConversation() -> Conversation {
        let conversation = Conversation(
            id: UUID(),
            title: "",
            lastMessagePreview: "",
            updatedAt: Date(),
            messages: []
        )
        conversations.insert(conversation, at: 0)
        save()
        return conversation
    }

    func conversation(with id: UUID) -> Conversation? {
        conversations.first { $0.id == id }
    }

    func updateConversation(id: UUID, messages: [ChatMessage]) {
        guard let index = conversations.firstIndex(where: { $0.id == id }) else { return }

        var conv = conversations[index]
        conv.messages = messages
        if let last = messages.last {
            conv.lastMessagePreview = last.text
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
