import Foundation

/// Ajuda a calcular intervalos de um mês e a filtrar/navegar entre meses.
enum MonthFilter {
    private static var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Formatters.ptBR
        return cal
    }

    /// Primeiro instante do mês que contém `date`.
    static func startOfMonth(for date: Date) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps) ?? date
    }

    /// Avança ou retrocede `value` meses a partir de `date`.
    static func month(byAdding value: Int, to date: Date) -> Date {
        calendar.date(byAdding: .month, value: value, to: date) ?? date
    }

    /// Verdadeiro se `date` está no mesmo mês/ano de `reference`.
    static func isSameMonth(_ date: Date, as reference: Date) -> Bool {
        calendar.isDate(date, equalTo: reference, toGranularity: .month)
    }
}
