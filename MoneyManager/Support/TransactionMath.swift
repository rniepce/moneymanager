import Foundation

/// Cálculos financeiros compartilhados sobre coleções de lançamentos.
/// Usados pelo Resumo, pela lista do mês e pelo contexto enviado à IA —
/// uma única fonte de verdade para as somas.
extension Collection where Element == Transaction {
    /// Soma das receitas.
    var totalIncome: Decimal {
        filter { $0.type == .income }.reduce(Decimal(0)) { $0 + $1.amount }
    }

    /// Soma das despesas.
    var totalExpense: Decimal {
        filter { $0.type == .expense }.reduce(Decimal(0)) { $0 + $1.amount }
    }

    /// Receitas menos despesas.
    var balance: Decimal {
        totalIncome - totalExpense
    }

    /// Total gasto por categoria (apenas categorias com valor > 0),
    /// da maior para a menor.
    var expensesByCategory: [(category: ExpenseCategory, total: Decimal)] {
        ExpenseCategory.allCases
            .map { cat in
                (category: cat,
                 total: filter { $0.type == .expense && $0.category == cat }
                    .reduce(Decimal(0)) { $0 + $1.amount })
            }
            .filter { $0.total > 0 }
            .sorted { $0.total > $1.total }
    }

    /// Apenas os lançamentos do mês que contém `date`.
    func inMonth(of date: Date) -> [Transaction] {
        filter { MonthFilter.isSameMonth($0.date, as: date) }
    }
}
