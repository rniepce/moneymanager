import SwiftUI
import SwiftData

/// Resumo do mês selecionado: saldo, totais e gasto por categoria.
/// Fica escondido atrás de um botão para não gerar ansiedade no dia a dia.
struct SummaryView: View {
    @Environment(\.dismiss) private var dismiss

    /// Todos os lançamentos; o filtro por mês é feito em memória (volume baixo).
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]

    /// Mês atualmente exibido (começa no mês corrente).
    @State private var selectedMonth: Date = .now

    private var monthTransactions: [Transaction] {
        allTransactions.inMonth(of: selectedMonth)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    MonthNavigator(month: $selectedMonth)
                    balanceCard
                    categoriesCard
                    transactionsLink
                }
                .padding(20)
            }
            .background { Theme.screenBackground }
            .navigationTitle("Resumo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }

    // MARK: - Cartões

    /// Cartão principal: saldo grande + colunas de receitas e despesas.
    private var balanceCard: some View {
        let balance = monthTransactions.balance
        return VStack(spacing: 12) {
            Text("Saldo do mês")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(Formatters.currency(balance))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(balance >= 0 ? TransactionType.income.color : TransactionType.expense.color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Divider()

            HStack(spacing: 12) {
                statColumn(type: .income, value: monthTransactions.totalIncome)
                Divider().frame(height: 36)
                statColumn(type: .expense, value: monthTransactions.totalExpense)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    private func statColumn(type: TransactionType, value: Decimal) -> some View {
        VStack(spacing: 4) {
            Label(type == .income ? "Receitas" : "Despesas", systemImage: type.systemImage)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(Formatters.currency(value))
                .font(.callout.weight(.semibold))
                .foregroundStyle(type.color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    /// Cartão com o gasto de cada categoria e barra proporcional.
    private var categoriesCard: some View {
        let items = monthTransactions.expensesByCategory
        let totalExpense = monthTransactions.totalExpense
        return VStack(alignment: .leading, spacing: 14) {
            Text("Gasto por categoria")
                .font(.headline)

            if items.isEmpty {
                Text("Nenhuma despesa neste mês.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(items, id: \.category) { item in
                    categoryRow(item.category, total: item.total, of: totalExpense)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private func categoryRow(_ category: ExpenseCategory, total: Decimal, of totalExpense: Decimal) -> some View {
        let fraction = totalExpense > 0
            ? NSDecimalNumber(decimal: total / totalExpense).doubleValue
            : 0
        return HStack(spacing: 12) {
            CategoryBadge(systemImage: category.systemImage, color: category.color)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(category.label)
                        .font(.subheadline)
                    Spacer()
                    Text(Formatters.currency(total))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                ProgressView(value: min(fraction, 1))
                    .tint(category.color)
            }
        }
    }

    /// Cartão-link para ver e editar os lançamentos do mês.
    private var transactionsLink: some View {
        NavigationLink {
            MonthTransactionsView(month: selectedMonth)
        } label: {
            HStack {
                Label("Ver e editar lançamentos", systemImage: "list.bullet")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(20)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SummaryView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
