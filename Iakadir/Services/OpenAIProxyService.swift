import Foundation

struct OpenAIInputMessage: Encodable {
    let role: String
    let content: String
}

struct OpenAIProxyPayload: Encodable {
    let model: String
    let instructions: String?
    let input: [OpenAIInputMessage]
}

struct OpenAIProxyReply: Decodable {
    let text: String
}

final class OpenAIProxyService {

    
    
    private var functionURL: URL {
        URL(string: "https://wiscsyvsecetnfgrdyiu.supabase.co/functions/v1/rapid-processor")!
    }
    
    

    func generateText(
        input: [OpenAIInputMessage],
        instructions: String?,
        model: String = "gpt-4.1"
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

        let payload = OpenAIProxyPayload(model: model, instructions: instructions, input: input)
        req.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        guard (200...299).contains(http.statusCode) else {
            let raw = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "OpenAIProxyService", code: http.statusCode, userInfo: [
                NSLocalizedDescriptionKey: raw
            ])
        }

        return try JSONDecoder().decode(OpenAIProxyReply.self, from: data).text
    }
}
