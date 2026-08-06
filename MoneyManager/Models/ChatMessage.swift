import Foundation

/// Uma mensagem da conversa com a IA (em memória, não persistida).
struct ChatMessage: Identifiable, Equatable {
    enum Role: String {
        case system
        case user
        case assistant
    }

    let id: UUID
    let role: Role
    var content: String
    /// Raciocínio da IA, quando o modo raciocínio do V4 Flash está ligado.
    var reasoning: String?

    init(id: UUID = UUID(), role: Role, content: String, reasoning: String? = nil) {
        self.id = id
        self.role = role
        self.content = content
        self.reasoning = reasoning
    }
}
