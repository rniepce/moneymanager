import SwiftUI

/// Navegador de mês (◀ nome do mês ▶), reutilizável em qualquer tela.
struct MonthNavigator: View {
    @Binding var month: Date

    var body: some View {
        HStack {
            navButton(symbol: "chevron.left", delta: -1, label: "Mês anterior")
            Spacer()
            Text(Formatters.monthYear(month).capitalized)
                .font(.headline)
            Spacer()
            navButton(symbol: "chevron.right", delta: 1, label: "Próximo mês")
        }
        .padding(.horizontal, 4)
    }

    private func navButton(symbol: String, delta: Int, label: String) -> some View {
        Button {
            withAnimation(.snappy) {
                month = MonthFilter.month(byAdding: delta, to: month)
            }
        } label: {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .frame(width: 36, height: 36)
                .background(Color(.secondarySystemGroupedBackground), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
