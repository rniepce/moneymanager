import SwiftUI
import SwiftData

/// Lista dos lançamentos de um mês. Permite ver, editar (tocando), excluir
/// (deslizando) e adicionar um novo item já naquele mês (botão +).
struct MonthTransactionsView: View {
    @Environment(\.modelContext) private var modelContext

    let month: Date

    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]

    @State private var editing: Transaction?
    @State private var creatingType: TransactionType?

    private var transactions: [Transaction] {
        allTransactions.inMonth(of: month)
    }

    var body: some View {
        List {
            if transactions.isEmpty {
                ContentUnavailableView(
                    "Nenhum lançamento",
                    systemImage: "tray",
                    description: Text("Toque em + para adicionar neste mês.")
                )
            } else {
                ForEach(transactions) { transaction in
                    Button {
                        editing = transaction
                    } label: {
                        TransactionRow(transaction: transaction)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: delete)
            }
        }
        .navigationTitle(Formatters.monthYear(month).capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        creatingType = .income
                    } label: {
                        Label("Nova receita", systemImage: TransactionType.income.systemImage)
                    }
                    Button {
                        creatingType = .expense
                    } label: {
                        Label("Nova despesa", systemImage: TransactionType.expense.systemImage)
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $editing) { transaction in
            TransactionEditorView(editing: transaction)
        }
        .sheet(item: $creatingType) { type in
            // Novo item posicionado no mês exibido.
            TransactionEditorView(type: type, defaultDate: defaultDateForNew)
        }
    }

    /// Data padrão para novos itens: hoje se estivermos no mês corrente,
    /// senão o primeiro dia do mês exibido.
    private var defaultDateForNew: Date {
        MonthFilter.isSameMonth(.now, as: month)
            ? .now
            : MonthFilter.startOfMonth(for: month)
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(transactions[index])
        }
    }
}

#Preview {
    NavigationStack {
        MonthTransactionsView(month: .now)
    }
    .modelContainer(for: Transaction.self, inMemory: true)
}
