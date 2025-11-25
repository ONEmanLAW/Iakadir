//
//  ChatStore.swift
//  Iakadir
//
//  Created by digital on 25/11/2025.
//

import Foundation

struct Conversation: Identifiable, Codable {
    var id: UUID
    var title: String
    var lastMessagePreview: String
    var updatedAt: Date
    var messages: [ChatMessage]
}

@MainActor
class ChatStore: ObservableObject {
    @Published var conversations: [Conversation] = []

    private let storageKey = "chat_conversations_v1"

    init() {
        load()
    }

    // Charger depuis UserDefaults
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([Conversation].self, from: data)
            conversations = decoded
        } catch {
            print("Erreur decode conversations:", error)
        }
    }

    // Sauvegarder dans UserDefaults
    private func save() {
        do {
            let data = try JSONEncoder().encode(conversations)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Erreur encode conversations:", error)
        }
    }

    // Créer une nouvelle conversation (depuis la carte "Parler à l’IA")
    func createConversation() -> Conversation {
        let conversation = Conversation(
            id: UUID(),
            title: "Nouvelle conversation",
            lastMessagePreview: "",
            updatedAt: Date(),
            messages: []
        )
        conversations.insert(conversation, at: 0) // en haut de la liste
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
}
