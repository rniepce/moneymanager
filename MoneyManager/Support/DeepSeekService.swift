import Foundation

/// Erros amigáveis da conversa com a IA.
enum DeepSeekError: LocalizedError {
    case missingKey
    case invalidURL
    case unauthorized
    case server(status: Int, message: String?)
    case emptyResponse
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .missingKey:
            return "Nenhuma chave da DeepSeek configurada. Abra os Ajustes e cole sua chave."
        case .invalidURL:
            return "O endereço da API está inválido. Verifique nos Ajustes."
        case .unauthorized:
            return "Chave da DeepSeek inválida ou sem crédito. Confira nos Ajustes."
        case let .server(status, message):
            return "A IA retornou um erro (\(status))." + (message.map { " \($0)" } ?? "")
        case .emptyResponse:
            return "A IA não retornou nenhuma resposta. Tente novamente."
        case let .network(error):
            return "Falha de conexão: \(error.localizedDescription)"
        }
    }
}

/// Cliente da API de chat da DeepSeek (compatível com OpenAI).
struct DeepSeekService {
    // MARK: - Modelos de requisição/resposta

    private struct RequestBody: Encodable {
        let model: String
        let messages: [Message]
        let stream: Bool

        struct Message: Encodable {
            let role: String
            let content: String
        }
    }

    private struct ResponseBody: Decodable {
        let choices: [Choice]

        struct Choice: Decodable {
            let message: Message
        }
        struct Message: Decodable {
            let content: String
        }
    }

    private struct ErrorBody: Decodable {
        let error: ErrorDetail?
        struct ErrorDetail: Decodable { let message: String? }
    }

    // MARK: - Envio

    /// Envia as mensagens e devolve o texto da resposta da IA.
    func send(messages: [ChatMessage]) async throws -> String {
        let key = AISettings.apiKey
        guard !key.isEmpty else { throw DeepSeekError.missingKey }

        var base = AISettings.baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        while base.hasSuffix("/") { base.removeLast() }
        guard let url = URL(string: base + "/chat/completions") else {
            throw DeepSeekError.invalidURL
        }

        let body = RequestBody(
            model: AISettings.model,
            messages: messages.map { .init(role: $0.role.rawValue, content: $0.content) },
            stream: false
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = 60

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw DeepSeekError.network(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw DeepSeekError.emptyResponse
        }

        guard (200...299).contains(http.statusCode) else {
            if http.statusCode == 401 { throw DeepSeekError.unauthorized }
            let message = (try? JSONDecoder().decode(ErrorBody.self, from: data))?.error?.message
            throw DeepSeekError.server(status: http.statusCode, message: message)
        }

        let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
        let content = decoded.choices.first?.message.content
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let content, !content.isEmpty else {
            throw DeepSeekError.emptyResponse
        }
        return content
    }
}
