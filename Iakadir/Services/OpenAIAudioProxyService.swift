import Foundation

struct OpenAIAudioProxyPayload: Encodable {
    let model: String
    let prompt: String?
    let filename: String
    let audioBase64: String
}

struct OpenAIAudioProxyReply: Decodable {
    let text: String
}

final class OpenAIAudioProxyService {

    private var functionURL: URL {
        SupabaseConfig.url.appendingPathComponent("functions/v1/openai-audio")
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

        req.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")

        if let session = try? await supabase.auth.session {
            req.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            req.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")
        }

        let payload = OpenAIAudioProxyPayload(
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
