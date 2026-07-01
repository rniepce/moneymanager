import SwiftUI

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
            VStack(spacing: 20) {
                Spacer()

                Text("O que você quer anotar?")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)

                choiceButton(for: .income)
                choiceButton(for: .expense)

                Spacer()
                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
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

    private func choiceButton(for type: TransactionType) -> some View {
        Button {
            editorType = type
        } label: {
            HStack(spacing: 16) {
                Image(systemName: type.systemImage)
                    .font(.system(size: 34))
                Text(type.label)
                    .font(.title.weight(.bold))
                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white)
            .background(type.color, in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
