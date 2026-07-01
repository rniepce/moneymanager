import SwiftUI

/// Tipo de lançamento: entrada de dinheiro (receita) ou saída (despesa).
enum TransactionType: String, CaseIterable, Identifiable {
    case income   // receita
    case expense  // despesa

    var id: String { rawValue }

    /// Nome exibido em português.
    var label: String {
        switch self {
        case .income:  return "Receita"
        case .expense: return "Despesa"
        }
    }

    /// Ícone (SF Symbol) usado nos botões e listas.
    var systemImage: String {
        switch self {
        case .income:  return "arrow.down.circle.fill"
        case .expense: return "arrow.up.circle.fill"
        }
    }

    /// Cor associada ao tipo.
    var color: Color {
        switch self {
        case .income:  return Color(red: 0.16, green: 0.55, blue: 0.42) // verde suave
        case .expense: return Color(red: 0.78, green: 0.36, blue: 0.36) // vermelho suave
        }
    }
}
