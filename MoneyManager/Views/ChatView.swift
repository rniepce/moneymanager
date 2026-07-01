import SwiftUI
import SwiftData

/// Chat com a IA (DeepSeek) para conversar sobre os dados salvos no app.
struct ChatView: View {
    @Environment(\.dismiss) private var dismiss

    @Query private var transactions: [Transaction]

    @State private var messages: [ChatMessage] = [
        ChatMessage(
            role: .assistant,
            content: "Oi! Sou seu assistente de finanças. Posso te ajudar a "
                + "entender seus gastos e receitas. O que você quer saber?"
        )
    ]
    @State private var draft: String = ""
    @State private var isSending = false
    @State private var errorMessage: String?
    @State private var showSettings = false

    private let service = DeepSeekService()

    private var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !AISettings.isConfigured {
                    configBanner
                }

                messagesList

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                }

                inputBar
            }
            .navigationTitle("Conversar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Ajustes")
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    // MARK: - Componentes

    private var configBanner: some View {
        Button {
            showSettings = true
        } label: {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                Text("Configure sua chave da DeepSeek para começar.")
                    .font(.footnote)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .background(Color.yellow.opacity(0.2))
        }
        .buttonStyle(.plain)
    }

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages.filter { $0.role != .system }) { message in
                        bubble(for: message)
                            .id(message.id)
                    }
                    if isSending {
                        HStack {
                            ProgressView()
                            Text("Digitando…")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .id("typing")
                    }
                }
                .padding()
            }
            .onChange(of: messages.count) { _, _ in scrollToBottom(proxy) }
            .onChange(of: isSending) { _, _ in scrollToBottom(proxy) }
        }
    }

    private func bubble(for message: ChatMessage) -> some View {
        let isUser = message.role == .user
        return HStack {
            if isUser { Spacer(minLength: 40) }
            Text(message.content)
                .padding(12)
                .foregroundStyle(isUser ? .white : .primary)
                .background(
                    isUser ? Color.accentColor : Color(.secondarySystemBackground),
                    in: RoundedRectangle(cornerRadius: 16)
                )
            if !isUser { Spacer(minLength: 40) }
        }
        .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Escreva sua pergunta…", text: $draft, axis: .vertical)
                .lineLimit(1...4)
                .padding(10)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))

            Button {
                Task { await sendMessage() }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
            }
            .disabled(!canSend)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    // MARK: - Ações

    private func sendMessage() async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        errorMessage = nil
        draft = ""
        messages.append(ChatMessage(role: .user, content: text))
        isSending = true
        defer { isSending = false }

        // Monta system prompt (contexto atual) + histórico da conversa.
        let context = FinanceContext.build(from: transactions)
        let system = ChatMessage(role: .system, content: FinanceContext.systemPrompt(context: context))
        let payload = [system] + messages.filter { $0.role != .system }

        do {
            let reply = try await service.send(messages: payload)
            messages.append(ChatMessage(role: .assistant, content: reply))
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation {
            if isSending {
                proxy.scrollTo("typing", anchor: .bottom)
            } else if let last = messages.last {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }
}

#Preview {
    ChatView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
