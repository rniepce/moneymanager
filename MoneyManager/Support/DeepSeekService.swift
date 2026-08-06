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
    /// Resposta da IA: o texto para o usuário e, no modo raciocínio do V4
    /// Flash, o passo a passo que o modelo pensou antes de responder.
    struct Reply {
        let content: String
        let reasoning: String?
    }

    // MARK: - Modelos de requisição/resposta

    private struct RequestBody: Encodable {
        let model: String
        let messages: [Message]
        let stream: Bool
        /// Só é enviado nos modelos V4, que aceitam ligar/desligar o raciocínio.
        let thinking: Thinking?

        struct Message: Encodable {
            let role: String
            let content: String
        }

        struct Thinking: Encodable {
            let type: String

            static let enabled = Thinking(type: "enabled")
            static let disabled = Thinking(type: "disabled")
        }
    }

    private struct ResponseBody: Decodable {
        let choices: [Choice]

        struct Choice: Decodable {
            let message: Message
        }
        struct Message: Decodable {
            let content: String
            /// Presente apenas quando o modo raciocínio está ligado.
            let reasoningContent: String?

            enum CodingKeys: String, CodingKey {
                case content
                case reasoningContent = "reasoning_content"
            }
        }
    }

    private struct ErrorBody: Decodable {
        let error: ErrorDetail?
        struct ErrorDetail: Decodable { let message: String? }
    }

    // MARK: - Envio

    /// Envia as mensagens e devolve a resposta da IA.
    func send(messages: [ChatMessage]) async throws -> Reply {
        let key = AISettings.apiKey
        guard !key.isEmpty else { throw DeepSeekError.missingKey }

        var base = AISettings.baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        while base.hasSuffix("/") { base.removeLast() }
        guard let url = URL(string: base + "/chat/completions") else {
            throw DeepSeekError.invalidURL
        }

        let model = AISettings.model
        let thinkingEnabled = AISettings.isThinkingEnabled
        // Modelos legados (deepseek-chat/reasoner) já trazem o modo fixo no id
        // e não aceitam o campo `thinking`, então ele fica de fora.
        var thinking: RequestBody.Thinking?
        if supportsThinkingToggle(model: model) {
            thinking = thinkingEnabled ? RequestBody.Thinking.enabled : RequestBody.Thinking.disabled
        }

        let body = RequestBody(
            model: model,
            messages: messages.map { .init(role: $0.role.rawValue, content: $0.content) },
            stream: false,
            thinking: thinking
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)
        // Pensar leva mais tempo: damos mais folga quando o raciocínio está ligado.
        request.timeoutInterval = thinkingEnabled ? 180 : 60

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
        guard let message = decoded.choices.first?.message else {
            throw DeepSeekError.emptyResponse
        }

        let content = message.content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { throw DeepSeekError.emptyResponse }

        let reasoning = message.reasoningContent?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return Reply(
            content: content,
            reasoning: (reasoning?.isEmpty == false) ? reasoning : nil
        )
    }

    /// O campo `thinking` só existe nos modelos V4 da DeepSeek.
    private func supportsThinkingToggle(model: String) -> Bool {
        if let known = AIModel(rawValue: model) { return known.supportsThinkingToggle }
        return model.hasPrefix("deepseek-v4")
    }
}
