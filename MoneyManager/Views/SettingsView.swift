import SwiftUI

/// Ajustes da IA: chave da API da DeepSeek e id do modelo.
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var apiKey: String = ""
    @State private var model: String = AISettings.model
    @State private var hasSavedKey: Bool = AISettings.isConfigured
    @State private var showSavedAlert = false

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
                    TextField("Modelo", text: $model)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("Modelo")
                } footer: {
                    Text("Id do modelo da DeepSeek. O padrão é \(AISettings.defaultModel).")
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
        let trimmedModel = model.trimmingCharacters(in: .whitespacesAndNewlines)
        AISettings.model = trimmedModel.isEmpty ? AISettings.defaultModel : trimmedModel

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
