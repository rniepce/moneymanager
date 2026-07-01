import Foundation

/// Utilitários de formatação em português do Brasil (moeda e datas).
enum Formatters {
    /// Locale pt-BR usado em toda a formatação.
    static let ptBR = Locale(identifier: "pt_BR")

    /// Formata um valor como moeda em Reais, ex.: "R$ 1.234,56".
    static func currency(_ value: Decimal) -> String {
        value.formatted(.currency(code: "BRL").locale(ptBR))
    }

    /// Nome do mês e ano por extenso, ex.: "julho de 2026".
    static func monthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = ptBR
        formatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return formatter.string(from: date)
    }

    /// Data curta, ex.: "01/07/2026".
    static func shortDate(_ date: Date) -> String {
        date.formatted(.dateTime.locale(ptBR).day().month().year())
    }

    /// Dia e mês curtos, ex.: "01 de jul".
    static func dayMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = ptBR
        formatter.setLocalizedDateFormatFromTemplate("dd MMM")
        return formatter.string(from: date)
    }
}
