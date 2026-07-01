import SwiftUI
import SwiftData

/// Resumo do mês selecionado: saldo, total gasto e gasto por categoria.
/// Fica escondido atrás de um botão para não gerar ansiedade no dia a dia.
struct SummaryView: View {
    @Environment(\.dismiss) private var dismiss

    /// Todos os lançamentos; o filtro por mês é feito em memória (volume baixo).
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]

    /// Mês atualmente exibido (começa no mês corrente).
    @State private var selectedMonth: Date = .now

    /// Lançamentos do mês selecionado.
    private var monthTransactions: [Transaction] {
        allTransactions.filter { MonthFilter.isSameMonth($0.date, as: selectedMonth) }
    }

    private var totalIncome: Decimal {
        monthTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    private var totalExpense: Decimal {
        monthTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    private var balance: Decimal { totalIncome - totalExpense }

    /// Total gasto por categoria (só categorias com valor > 0), maior primeiro.
    private var byCategory: [(category: ExpenseCategory, total: Decimal)] {
        ExpenseCategory.allCases
            .map { cat in
                let total = monthTransactions
                    .filter { $0.type == .expense && $0.category == cat }
                    .reduce(Decimal(0)) { $0 + $1.amount }
                return (cat, total)
            }
            .filter { $0.total > 0 }
            .sorted { $0.total > $1.total }
    }

    var body: some View {
        NavigationStack {
            List {
                monthNavigator

                Section {
                    balanceRow
                    row(title: "Total de receitas", value: totalIncome, color: TransactionType.income.color)
                    row(title: "Total de despesas", value: totalExpense, color: TransactionType.expense.color)
                }

                Section("Gasto por categoria") {
                    if byCategory.isEmpty {
                        Text("Nenhuma despesa neste mês.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(byCategory, id: \.category) { item in
                            categoryRow(item.category, total: item.total)
                        }
                    }
                }

                Section {
                    NavigationLink {
                        MonthTransactionsView(month: selectedMonth)
                    } label: {
                        Label("Ver e editar lançamentos", systemImage: "list.bullet")
                    }
                }
            }
            .navigationTitle("Resumo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }

    // MARK: - Componentes

    private var monthNavigator: some View {
        HStack {
            Button {
                selectedMonth = MonthFilter.month(byAdding: -1, to: selectedMonth)
            } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(Formatters.monthYear(selectedMonth).capitalized)
                .font(.headline)
            Spacer()
            Button {
                selectedMonth = MonthFilter.month(byAdding: 1, to: selectedMonth)
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .buttonStyle(.borderless)
    }

    private var balanceRow: some View {
        HStack {
            Text("Saldo")
                .font(.headline)
            Spacer()
            Text(Formatters.currency(balance))
                .font(.headline)
                .foregroundStyle(balance >= 0 ? TransactionType.income.color : TransactionType.expense.color)
        }
    }

    private func row(title: String, value: Decimal, color: Color) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(Formatters.currency(value))
                .foregroundStyle(color)
        }
    }

    private func categoryRow(_ category: ExpenseCategory, total: Decimal) -> some View {
        let fraction = totalExpense > 0
            ? NSDecimalNumber(decimal: total / totalExpense).doubleValue
            : 0
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(category.label, systemImage: category.systemImage)
                    .foregroundStyle(category.color)
                Spacer()
                Text(Formatters.currency(total))
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: fraction)
                .tint(category.color)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    SummaryView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
