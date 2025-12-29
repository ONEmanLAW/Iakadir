//
//  OpenAIAudioProxyService.swift
//  Iakadir
//
//  Created by digital on 29/12/2025.
//

import Foundation

struct OpenAIAudioProxyPayload: Encodable {
    let task: String            // "audio"
    let model: String           // "gpt-4o-mini-transcribe"
    let prompt: String?
    let filename: String
    let audioBase64: String
}

struct OpenAIAudioProxyReply: Decodable {
    let text: String
}

final class OpenAIAudioProxyService {

    // ✅ Une seule function: openai-chat
    private var functionURL: URL {
        SupabaseConfig.url.appendingPathComponent("functions/v1/openai-chat")
    }

    func transcribeMP3(
        audioData: Data,
        filename: String,
        prompt: String?,
        model: String = "gpt-4o-mini-transcribe"
    ) async throws -> String {

        var req = URLRequest(url: functionURL)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Supabase Edge Function headers
        req.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")

        if let session = try? await supabase.auth.session {
            req.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            req.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")
        }

        let payload = OpenAIAudioProxyPayload(
            task: "audio",
            model: model,
            prompt: prompt,
            filename: filename,
            audioBase64: audioData.base64EncodedString()
        )

        req.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        guard (200...299).contains(http.statusCode) else {
            let raw = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "OpenAIAudioProxyService", code: http.statusCode, userInfo: [
                NSLocalizedDescriptionKey: raw
            ])
        }

        return try JSONDecoder().decode(OpenAIAudioProxyReply.self, from: data).text
    }
}
