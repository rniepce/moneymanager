import Foundation

/// Modelos da DeepSeek conhecidos pelo app. O usuário ainda pode digitar
/// qualquer outro id nos Ajustes — esta lista é só um atalho.
enum AIModel: String, CaseIterable, Identifiable {
    /// Modelo padrão: rápido, contexto grande e com modo raciocínio opcional.
    case v4Flash = "deepseek-v4-flash"
    /// Apelido legado que aponta para o V4 Flash sem raciocínio.
    case chat = "deepseek-chat"
    /// Apelido legado que aponta para o V4 Flash com raciocínio.
    case reasoner = "deepseek-reasoner"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .v4Flash: return "DeepSeek V4 Flash"
        case .chat: return "deepseek-chat (legado)"
        case .reasoner: return "deepseek-reasoner (legado)"
        }
    }

    /// Só o V4 aceita o campo `thinking` para ligar/desligar o raciocínio;
    /// nos apelidos legados o modo já vem fixo no próprio id.
    var supportsThinkingToggle: Bool { self == .v4Flash }
}

/// Configurações da IA (DeepSeek). A chave fica no Keychain; modelo, modo de
/// raciocínio e endereço ficam nas preferências (UserDefaults).
enum AISettings {
    private static let keychainAccount = "deepseek.apiKey"
    private static let modelKey = "ai.model"
    private static let baseURLKey = "ai.baseURL"
    private static let thinkingKey = "ai.thinking"
    private static let migrationKey = "ai.migratedToV4Flash"

    static let defaultModel = AIModel.v4Flash.rawValue
    static let defaultBaseURL = "https://api.deepseek.com"

    /// Modelo padrão das versões anteriores do app, migrado para o V4 Flash.
    private static let legacyDefaultModel = AIModel.chat.rawValue

    /// Chave da API guardada no Keychain.
    static var apiKey: String {
        get { KeychainHelper.read(for: keychainAccount) ?? "" }
        set {
            let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                KeychainHelper.delete(for: keychainAccount)
            } else {
                KeychainHelper.save(trimmed, for: keychainAccount)
            }
        }
    }

    /// Id do modelo da DeepSeek (ex.: "deepseek-v4-flash").
    static var model: String {
        get {
            let value = UserDefaults.standard.string(forKey: modelKey) ?? ""
            return value.isEmpty ? defaultModel : value
        }
        set { UserDefaults.standard.set(newValue, forKey: modelKey) }
    }

    /// Modelo escolhido, quando ele é um dos conhecidos pelo app.
    static var knownModel: AIModel? { AIModel(rawValue: model) }

    /// Liga o modo raciocínio do V4 Flash: respostas mais bem pensadas, porém
    /// mais lentas. Desligado por padrão para o chat ficar ágil.
    static var isThinkingEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: thinkingKey) }
        set { UserDefaults.standard.set(newValue, forKey: thinkingKey) }
    }

    /// Endereço base da API.
    static var baseURL: String {
        get {
            let value = UserDefaults.standard.string(forKey: baseURLKey) ?? ""
            return value.isEmpty ? defaultBaseURL : value
        }
        set { UserDefaults.standard.set(newValue, forKey: baseURLKey) }
    }

    /// Verdadeiro quando há uma chave salva.
    static var isConfigured: Bool { !apiKey.isEmpty }

    /// Atualiza quem ainda estava no modelo padrão antigo (`deepseek-chat`)
    /// para o V4 Flash. Roda uma única vez; quem escolheu outro modelo de
    /// propósito não é afetado.
    static func migrateIfNeeded() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: migrationKey) else { return }
        defaults.set(true, forKey: migrationKey)

        let saved = defaults.string(forKey: modelKey) ?? ""
        if saved.isEmpty || saved == legacyDefaultModel {
            model = defaultModel
        }
    }
}
