import SwiftUI
import SwiftData

/// Formulário único usado tanto para **criar** quanto para **editar** um
/// lançamento (receita ou despesa).
struct TransactionEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// Lançamento em edição (nil quando estamos criando um novo).
    private let existing: Transaction?
    private let type: TransactionType

    @State private var title: String
    @State private var amount: Decimal
    @State private var date: Date
    @State private var category: ExpenseCategory?

    /// Cria um novo lançamento do tipo indicado. `defaultDate` permite já
    /// posicionar o registro em um mês específico (usado pela lista do mês).
    init(type: TransactionType, defaultDate: Date = .now) {
        self.existing = nil
        self.type = type
        _title = State(initialValue: "")
        _amount = State(initialValue: 0)
        _date = State(initialValue: defaultDate)
        _category = State(initialValue: type == .expense ? .supermercado : nil)
    }

    /// Edita um lançamento existente.
    init(editing transaction: Transaction) {
        self.existing = transaction
        self.type = transaction.type
        _title = State(initialValue: transaction.title)
        _amount = State(initialValue: transaction.amount)
        _date = State(initialValue: transaction.date)
        _category = State(initialValue: transaction.category)
    }

    private var isExpense: Bool { type == .expense }

    private var titlePrompt: String { isExpense ? "Título" : "Causa" }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && amount > 0
            && (!isExpense || category != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(titlePrompt, text: $title)
                    CurrencyField(title: "Valor", value: $amount)
                    DatePicker("Data", selection: $date, displayedComponents: .date)
                        .environment(\.locale, Formatters.ptBR)
                }

                if isExpense {
                    Section("Categoria") {
                        categoryGrid
                            .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                    }
                }
            }
            .navigationTitle(existing == nil ? "Nova \(type.label)" : "Editar \(type.label)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar", action: save)
                        .disabled(!canSave)
                }
            }
        }
    }

    private var categoryGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
            ForEach(ExpenseCategory.allCases) { cat in
                let selected = category == cat
                Button {
                    category = cat
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: cat.systemImage)
                            .font(.title3)
                        Text(cat.label)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(selected ? .white : cat.color)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selected ? cat.color : cat.color.opacity(0.12))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func save() {
        let cleanTitle = title.trimmingCharacters(in: .whitespaces)
        if let existing {
            existing.title = cleanTitle
            existing.amount = amount
            existing.date = date
            existing.type = type
            existing.category = isExpense ? category : nil
        } else {
            let new = Transaction(
                date: date,
                title: cleanTitle,
                amount: amount,
                type: type,
                category: isExpense ? category : nil
            )
            modelContext.insert(new)
        }
        dismiss()
    }
}

#Preview("Despesa") {
    TransactionEditorView(type: .expense)
        .modelContainer(for: Transaction.self, inMemory: true)
}

#Preview("Receita") {
    TransactionEditorView(type: .income)
        .modelContainer(for: Transaction.self, inMemory: true)
}
