import SwiftUI

/// Categorias de despesa disponíveis para classificar os gastos.
enum ExpenseCategory: String, CaseIterable, Identifiable {
    case transporte
    case saude
    case supermercado
    case saidas
    case extras
    case ferias
    case despesasFixas

    var id: String { rawValue }

    /// Nome exibido em português.
    var label: String {
        switch self {
        case .transporte:    return "Transporte"
        case .saude:         return "Saúde"
        case .supermercado:  return "Supermercado"
        case .saidas:        return "Saídas"
        case .extras:        return "Extras"
        case .ferias:        return "Férias"
        case .despesasFixas: return "Despesas fixas"
        }
    }

    /// Ícone (SF Symbol) da categoria.
    var systemImage: String {
        switch self {
        case .transporte:    return "car.fill"
        case .saude:         return "cross.case.fill"
        case .supermercado:  return "cart.fill"
        case .saidas:        return "wineglass.fill"
        case .extras:        return "sparkles"
        case .ferias:        return "beach.umbrella.fill"
        case .despesasFixas: return "calendar.badge.clock"
        }
    }

    /// Cor da categoria (tons suaves para uma interface calma).
    var color: Color {
        switch self {
        case .transporte:    return Color(red: 0.30, green: 0.55, blue: 0.78)
        case .saude:         return Color(red: 0.85, green: 0.42, blue: 0.45)
        case .supermercado:  return Color(red: 0.36, green: 0.66, blue: 0.45)
        case .saidas:        return Color(red: 0.72, green: 0.45, blue: 0.72)
        case .extras:        return Color(red: 0.90, green: 0.62, blue: 0.30)
        case .ferias:        return Color(red: 0.30, green: 0.70, blue: 0.72)
        case .despesasFixas: return Color(red: 0.50, green: 0.52, blue: 0.58)
        }
    }
}
