import SwiftUI

/// Ajustes da IA: chave da API da DeepSeek, modelo e modo raciocínio.
struct SettingsView: View {
    /// Escolha do modelo: um dos conhecidos ou um id digitado à mão.
    private enum ModelChoice: Hashable {
        case known(AIModel)
        case custom
    }

    @Environment(\.dismiss) private var dismiss

    @State private var apiKey: String = ""
    @State private var modelChoice: ModelChoice =
        AISettings.knownModel.map(ModelChoice.known) ?? .custom
    @State private var customModel: String =
        AISettings.knownModel == nil ? AISettings.model : ""
    @State private var thinkingEnabled: Bool = AISettings.isThinkingEnabled
    @State private var hasSavedKey: Bool = AISettings.isConfigured
    @State private var showSavedAlert = false

    /// Id do modelo que será salvo, conforme a escolha atual da tela.
    private var selectedModel: String {
        switch modelChoice {
        case let .known(model):
            return model.rawValue
        case .custom:
            let trimmed = customModel.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? AISettings.defaultModel : trimmed
        }
    }

    /// O modo raciocínio só aparece nos modelos V4, que aceitam ligá-lo/desligá-lo.
    private var showsThinkingToggle: Bool {
        if let known = AIModel(rawValue: selectedModel) { return known.supportsThinkingToggle }
        return selectedModel.hasPrefix("deepseek-v4")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField(
                        hasSavedKey ? "Chave salva — digite para trocar" : "Cole sua chave da DeepSeek",
                        text: $apiKey
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    if hasSavedKey {
                        Button("Apagar chave", role: .destructive, action: deleteKey)
                    }
                } header: {
                    Text("Chave da API")
                } footer: {
                    Text("A chave fica guardada com segurança no seu aparelho (Keychain). "
                         + "Você obtém uma chave em platform.deepseek.com.")
                }

                Section {
                    Picker("Modelo", selection: $modelChoice) {
                        ForEach(AIModel.allCases) { model in
                            Text(model.label).tag(ModelChoice.known(model))
                        }
                        Text("Outro (digitar id)").tag(ModelChoice.custom)
                    }

                    if modelChoice == .custom {
                        TextField("Id do modelo", text: $customModel)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                } header: {
                    Text("Modelo")
                } footer: {
                    Text("O padrão é o \(AIModel.v4Flash.label) — id \(AIModel.v4Flash.rawValue), "
                         + "rápido e com contexto grande. Os ids legados continuam "
                         + "funcionando se sua conta ainda usar um deles.")
                }

                if showsThinkingToggle {
                    Section {
                        Toggle("Modo raciocínio", isOn: $thinkingEnabled)
                    } footer: {
                        Text("Ligado, a IA pensa antes de responder: respostas mais "
                             + "cuidadosas em perguntas com contas, porém mais lentas. "
                             + "Você pode abrir o \"Como pensei\" embaixo da resposta.")
                    }
                }

                Section {
                    Text("Ao usar o chat, seus lançamentos (títulos, valores, categorias e "
                         + "datas) são enviados aos servidores da DeepSeek para a IA responder.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar", action: save)
                }
            }
            .alert("Ajustes salvos", isPresented: $showSavedAlert) {
                Button("OK") { dismiss() }
            }
        }
    }

    private func save() {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedKey.isEmpty {
            AISettings.apiKey = trimmedKey
        }
        let model = selectedModel
        AISettings.model = model
        AISettings.isThinkingEnabled = showsThinkingToggle ? thinkingEnabled : false

        if modelChoice == .custom, let known = AIModel(rawValue: model) {
            // O usuário digitou um id que o app já conhece: volta para a lista.
            modelChoice = .known(known)
            customModel = ""
        }

        apiKey = ""
        hasSavedKey = AISettings.isConfigured
        showSavedAlert = true
    }

    private func deleteKey() {
        AISettings.apiKey = ""
        apiKey = ""
        hasSavedKey = false
    }
}

#Preview {
    SettingsView()
}
