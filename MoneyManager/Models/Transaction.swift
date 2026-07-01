import Foundation
import SwiftData

/// Um lançamento financeiro salvo localmente (SwiftData).
///
/// O SwiftData persiste tipos primitivos, então guardamos o tipo e a categoria
/// como `String` (`typeRaw` / `categoryRaw`) e expomos os enums por meio de
/// propriedades computadas.
@Model
final class Transaction {
    var id: UUID
    var date: Date
    var title: String
    var amount: Decimal
    var typeRaw: String
    var categoryRaw: String?

    init(
        id: UUID = UUID(),
        date: Date = .now,
        title: String,
        amount: Decimal,
        type: TransactionType,
        category: ExpenseCategory? = nil
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.amount = amount
        self.typeRaw = type.rawValue
        self.categoryRaw = category?.rawValue
    }

    /// Tipo do lançamento (receita ou despesa).
    var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .expense }
        set { typeRaw = newValue.rawValue }
    }

    /// Categoria (apenas para despesas).
    var category: ExpenseCategory? {
        get { categoryRaw.flatMap(ExpenseCategory.init(rawValue:)) }
        set { categoryRaw = newValue?.rawValue }
    }
}
