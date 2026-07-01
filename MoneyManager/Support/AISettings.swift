import Foundation

/// Configurações da IA (DeepSeek). A chave fica no Keychain; modelo e endereço
/// ficam nas preferências (UserDefaults).
enum AISettings {
    private static let keychainAccount = "deepseek.apiKey"
    private static let modelKey = "ai.model"
    private static let baseURLKey = "ai.baseURL"

    static let defaultModel = "deepseek-chat"
    static let defaultBaseURL = "https://api.deepseek.com"

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

    /// Id do modelo da DeepSeek (ex.: "deepseek-chat").
    static var model: String {
        get {
            let value = UserDefaults.standard.string(forKey: modelKey) ?? ""
            return value.isEmpty ? defaultModel : value
        }
        set { UserDefaults.standard.set(newValue, forKey: modelKey) }
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
}
