import SwiftUI
import SwiftData

/// Tela inicial minimalista: apenas os botões de Receita e Despesa.
///
/// Nenhum total ou saldo aparece aqui — de propósito, para não gerar ansiedade
/// ao ver os gastos crescendo. O resumo fica escondido atrás de um botão
/// discreto no topo.
struct HomeView: View {
    @State private var editorType: TransactionType?
    @State private var showingSummary = false
    @State private var showingChat = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()

                VStack(spacing: 6) {
                    Text(greeting)
                        .font(.system(.largeTitle, design: .rounded).bold())
                    Text("O que você quer anotar hoje?")
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 20)

                choiceCard(for: .income, subtitle: "Salário, vendas, presentes…")
                choiceCard(for: .expense, subtitle: "Compras, contas, passeios…")

                Spacer()
                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { Theme.screenBackground }
            .navigationTitle("Meu Dinheiro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingChat = true
                    } label: {
                        Image(systemName: "bubble.left.and.text.bubble.right")
                    }
                    .accessibilityLabel("Conversar com a IA")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSummary = true
                    } label: {
                        Image(systemName: "chart.pie")
                    }
                    .accessibilityLabel("Ver resumo")
                }
            }
            .sheet(item: $editorType) { type in
                TransactionEditorView(type: type)
            }
            .sheet(isPresented: $showingSummary) {
                SummaryView()
            }
            .sheet(isPresented: $showingChat) {
                ChatView()
            }
        }
    }

    /// Saudação de acordo com a hora do dia.
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Bom dia"
        case 12..<18: return "Boa tarde"
        default: return "Boa noite"
        }
    }

    private func choiceCard(for type: TransactionType, subtitle: String) -> some View {
        Button {
            editorType = type
        } label: {
            HStack(spacing: 16) {
                Image(systemName: type.systemImage)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(type.color, in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(type.label)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(18)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
