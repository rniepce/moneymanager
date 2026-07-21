import SwiftUI

/// Linha de lançamento usada nas listas: selo colorido, título,
/// categoria/data e valor.
struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            CategoryBadge(systemImage: transaction.displayIcon, color: transaction.displayColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(Formatters.currency(transaction.amount))
                .font(.callout.weight(.semibold))
                .foregroundStyle(transaction.type.color)
        }
        .padding(.vertical, 2)
    }

    private var subtitle: String {
        let date = Formatters.dayMonth(transaction.date)
        if transaction.type == .expense, let category = transaction.category {
            return "\(category.label) · \(date)"
        }
        return "\(transaction.type.label) · \(date)"
    }
}
