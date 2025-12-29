import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct SummarizeAudioView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var chatStore: ChatStore

    let conversationID: UUID?

    @State private var messages: [ChatMessage] = []
    @State private var resolvedConversationID: UUID?

    @State private var inputText: String = ""
    @State private var isSending: Bool = false

    // ✅ Import audio
    @State private var showImporter: Bool = false
    @State private var audioURL: URL?
    @State private var audioData: Data?
    @State private var audioFilename: String = ""

    private let audioAI = OpenAIAudioProxyService()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 12) {
                header

                if audioURL != nil {
                    selectedAudioPill
                }

                chatContent
                inputBar
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { setupConversation() }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: allowedAudioTypes(),
            allowsMultipleSelection: false
        ) { result in
            handleImporterResult(result)
        }
    }

    // MARK: - Header

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

            Text("Résumer un son")
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

    // MARK: - Audio pill

    private var selectedAudioPill: some View {
        HStack(spacing: 10) {
            Image(systemName: "waveform")
                .foregroundColor(.white.opacity(0.85))

            Text(audioFilename.isEmpty ? "Fichier audio" : audioFilename)
                .foregroundColor(.white)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(1)

            Spacer()

            Button {
                audioURL = nil
                audioData = nil
                audioFilename = ""
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.10)))
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(red: 0.07, green: 0.08, blue: 0.16))
        )
        .padding(.top, 4)
    }

    // MARK: - Chat content

    private var chatContent: some View {
        let lastBotId = messages.last(where: { !$0.isUser })?.id

        return ScrollView {
            VStack(spacing: 16) {
                if messages.isEmpty {
                    Text("Importe un fichier .mp3 puis écris ta demande (ex: “transcris et traduis en français”).")
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
                                        UIPasteboard.general.string = message.text
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
            .padding(.top, 6)
        }
    }

    // MARK: - Input bar

    private var inputBar: some View {
        HStack(spacing: 10) {
            Button { showImporter = true } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.10))
                        .frame(width: 38, height: 38)

                    Image(systemName: "paperclip")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.system(size: 16, weight: .semibold))
                }
            }

            TextField("Écris une demande ici", text: $inputText)
                .foregroundColor(.white)
                .font(.system(size: 15))
                .textInputAutocapitalization(.sentences)
                .disableAutocorrection(true)

            Button { sendMessage() } label: {
                ZStack {
                    Circle().fill(Color.primaryGreen).frame(width: 42, height: 42)
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .disabled(isSending)
            .opacity(isSending ? 0.5 : 1)
        }
        .padding(.horizontal, 14)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color(red: 0.07, green: 0.08, blue: 0.16))
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }

    // MARK: - Conversation store

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

        let newConv = chatStore.createConversation(mode: .summarizeAudio)
        resolvedConversationID = newConv.id
        messages = newConv.messages
    }

    private func persistMessages() {
        guard let id = resolvedConversationID else { return }
        chatStore.updateConversation(id: id, messages: messages)
    }

    // MARK: - Importer

    private func allowedAudioTypes() -> [UTType] {
        var types: [UTType] = []
        if let mp3 = UTType(filenameExtension: "mp3") { types.append(mp3) }
        if let m4a = UTType(filenameExtension: "m4a") { types.append(m4a) }
        return types.isEmpty ? [.audio] : types
    }

    private func handleImporterResult(_ result: Result<[URL], Error>) {
        switch result {
        case .failure:
            appendBot("Import annulé.")
            persistMessages()

        case .success(let urls):
            guard let url = urls.first else { return }

            let ok = url.startAccessingSecurityScopedResource()
            defer { if ok { url.stopAccessingSecurityScopedResource() } }

            do {
                let data = try Data(contentsOf: url)
                audioURL = url
                audioData = data
                audioFilename = url.lastPathComponent

                appendBot("Fichier importé ✅ Maintenant écris ta demande (transcrire / traduire…).")
                persistMessages()
            } catch {
                appendBot("Impossible de lire ce fichier audio.")
                persistMessages()
            }
        }
    }

    // MARK: - Envoi / Régénérer

    private func sendMessage() {
        Task { await sendMessageAsync() }
    }

    @MainActor
    private func sendMessageAsync() async {
        if isSending { return }

        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // 1) Bloque si pas de mp3
        guard let audioData, audioURL != nil else {
            inputText = ""
            appendBot("Non 😅 Il faut d’abord importer un fichier .mp3 (bouton trombone).")
            persistMessages()
            return
        }

        // 2) Bloque si fichier trop gros (très souvent la cause n°1)
        //    ⚠️ Base64 gonfle la taille, donc on limite (ex: 6MB)
        let maxBytes = 6 * 1024 * 1024
        if audioData.count > maxBytes {
            inputText = ""
            appendBot("Ton mp3 est trop gros pour l’instant 😅 Prends un fichier plus court (≈ 6 Mo max).")
            persistMessages()
            return
        }

        isSending = true

        // user message
        messages.append(ChatMessage(text: trimmed, isUser: true, kind: .text))
        inputText = ""

        // placeholder bot
        let placeholderID = UUID()
        messages.append(ChatMessage(id: placeholderID, text: "…", isUser: false, kind: .text))
        persistMessages()

        do {
            let reply = try await audioAI.transcribeMP3(
                audioData: audioData,
                filename: audioFilename.isEmpty ? "audio.mp3" : audioFilename,
                prompt: trimmed,
                model: "gpt-4o-mini-transcribe"
            )

            if let idx = messages.firstIndex(where: { $0.id == placeholderID }) {
                messages[idx].text = reply
            } else {
                messages.append(ChatMessage(text: reply, isUser: false, kind: .text))
            }

            persistMessages()
        } catch {
            // ✅ IMPORTANT: on log la vraie erreur en console (mais on affiche propre dans l’UI)
            print("❌ OpenAI Audio error:", (error as NSError).localizedDescription)

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

        guard let audioData else {
            appendBot("Impossible de régénérer : aucun fichier .mp3 importé.")
            persistMessages()
            return
        }

        guard let lastBotIndex = messages.lastIndex(where: { !$0.isUser }) else { return }
        guard let lastUser = messages.last(where: { $0.isUser }) else { return }

        isSending = true

        // remove last bot
        messages.remove(at: lastBotIndex)

        let placeholderID = UUID()
        messages.append(ChatMessage(id: placeholderID, text: "…", isUser: false, kind: .text))
        persistMessages()

        do {
            let reply = try await audioAI.transcribeMP3(
                audioData: audioData,
                filename: audioFilename.isEmpty ? "audio.mp3" : audioFilename,
                prompt: lastUser.text,
                model: "gpt-4o-mini-transcribe"
            )

            if let idx = messages.firstIndex(where: { $0.id == placeholderID }) {
                messages[idx].text = reply
            } else {
                messages.append(ChatMessage(text: reply, isUser: false, kind: .text))
            }

            persistMessages()
        } catch {
            print("❌ OpenAI Audio regen error:", (error as NSError).localizedDescription)

            let msg = userFriendlyErrorTextForRegenerate(error)
            if let idx = messages.firstIndex(where: { $0.id == placeholderID }) {
                messages[idx].text = msg
            }
            persistMessages()
        }

        isSending = false
    }

    // MARK: - Erreurs UX propres (plus précises)

    private func isQuotaOrBillingError(_ error: Error) -> Bool {
        let desc = (error as NSError).localizedDescription.lowercased()
        return desc.contains("insufficient_quota")
            || desc.contains("exceeded your current quota")
            || desc.contains("quota")
            || desc.contains("billing")
            || desc.contains("plan and billing")
    }

    private func userFriendlyErrorTextForSend(_ error: Error) -> String {
        let desc = (error as NSError).localizedDescription.lowercased()

        if isQuotaOrBillingError(error) {
            return "Ton mp3 et ta demande ont bien été pris en compte par ChatGPT, mais il n’y a plus assez de crédit sur le compte API, flemme de payer hehe."
        }

        // Cas très fréquents :
        if desc.contains("missing openai_api_key") || desc.contains("missing") && desc.contains("openai") {
            return "Ça a bien touché Supabase, mais il manque la clé OPENAI_API_KEY dans les Secrets."
        }

        if desc.contains("\"status\":401") || desc.contains("401") || desc.contains("unauthorized") {
            return "La function refuse l’accès (401). Vérifie “Verify JWT” (OFF) ou que l’utilisateur est connecté."
        }

        if desc.contains("413") || desc.contains("payload too large") || desc.contains("entity too large") {
            return "Ton mp3 est trop gros pour la function. Prends un fichier plus court."
        }

        if desc.contains("audio") && desc.contains("format") {
            return "Format audio non supporté. Essaie un vrai .mp3."
        }

        return "Erreur : l’API n’arrive pas à prendre en compte ton mp3 pour le moment."
    }

    private func userFriendlyErrorTextForRegenerate(_ error: Error) -> String {
        if isQuotaOrBillingError(error) {
            return "Ta demande a bien été régénérée et prise en compte par GPT, mais il n’y a plus assez de crédit sur le compte API, flemme de payer hehe."
        }
        return "Erreur : l’API n’arrive pas à prendre en compte la régénération."
    }

    // MARK: - Helpers

    private func appendBot(_ text: String) {
        messages.append(ChatMessage(text: text, isUser: false, kind: .text))
    }
}
