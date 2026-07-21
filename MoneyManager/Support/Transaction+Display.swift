import SwiftUI

/// Aparência de um lançamento nas listas (ícone e cor), derivada do tipo
/// e da categoria. Mantida fora do modelo para o modelo não depender de UI.
extension Transaction {
    /// Ícone exibido: o da categoria para despesas, a seta do tipo para receitas.
    var displayIcon: String {
        if type == .expense, let category = category {
            return category.systemImage
        }
        return type.systemImage
    }

    /// Cor exibida: a da categoria para despesas, a do tipo para receitas.
    var displayColor: Color {
        if type == .expense, let category = category {
            return category.color
        }
        return type.color
    }
}
