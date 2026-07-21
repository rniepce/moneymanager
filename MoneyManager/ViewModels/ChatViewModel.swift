import Foundation
import Observation

/// Estado e orquestração da conversa com a IA, separados da interface.
/// A `ChatView` só exibe o que está aqui; toda a lógica de envio fica neste
/// ViewModel, o que facilita testar e evoluir o chat sem mexer na tela.
@MainActor
@Observable
final class ChatViewModel {
    private(set) var messages: [ChatMessage]
    var draft: String = ""
    private(set) var isSending = false
    private(set) var errorMessage: String?

    private let service = DeepSeekService()

    init() {
        messages = [
            ChatMessage(
                role: .assistant,
                content: "Oi! Sou seu assistente de finanças. Posso te ajudar a "
                    + "entender seus gastos e receitas. O que você quer saber?"
            )
        ]
    }

    var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }

    /// Envia a mensagem digitada, usando os lançamentos como contexto factual.
    func send(using transactions: [Transaction]) async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSending else { return }

        errorMessage = nil
        draft = ""
        messages.append(ChatMessage(role: .user, content: text))
        isSending = true
        defer { isSending = false }

        let context = FinanceContext.build(from: transactions)
        let system = ChatMessage(role: .system, content: FinanceContext.systemPrompt(context: context))

        do {
            let reply = try await service.send(messages: [system] + messages)
            messages.append(ChatMessage(role: .assistant, content: reply))
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}
