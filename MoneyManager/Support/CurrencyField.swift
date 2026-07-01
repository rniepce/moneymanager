import SwiftUI

/// Campo de entrada de valor em Reais.
///
/// O usuário digita apenas números e eles são interpretados como centavos —
/// digitar `1`, `2`, `3`, `4` mostra "R$ 12,34". Isso evita confusão com
/// vírgula/ponto e deixa a digitação rápida no teclado numérico.
struct CurrencyField: View {
    let title: String
    @Binding var value: Decimal

    /// Texto interno com apenas dígitos (representa centavos).
    @State private var digits: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(Formatters.currency(value))
                .font(.title3.weight(.semibold))
                .foregroundStyle(value > 0 ? .primary : .secondary)
                // TextField invisível por cima captura a digitação numérica.
                .overlay(
                    TextField("", text: $digits)
                        .keyboardType(.numberPad)
                        .focused($isFocused)
                        .opacity(0.02)
                        .onChange(of: digits) { _, newValue in
                            updateValue(from: newValue)
                        }
                )
        }
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
        .onAppear { syncDigits(from: value) }
    }

    /// Converte a string de dígitos em Decimal (dividindo por 100).
    private func updateValue(from raw: String) {
        let filtered = String(raw.filter { $0.isNumber }.prefix(12))
        if filtered != raw {
            digits = filtered
            return
        }
        let cents = Decimal(string: filtered) ?? 0
        value = cents / 100
    }

    /// Preenche os dígitos a partir de um valor inicial (modo edição).
    private func syncDigits(from value: Decimal) {
        guard value > 0 else { digits = ""; return }
        let cents = NSDecimalNumber(decimal: value * 100).intValue
        digits = String(cents)
    }
}
