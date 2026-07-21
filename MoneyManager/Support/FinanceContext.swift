import Foundation

/// Monta o texto de contexto com os dados financeiros para enviar à IA.
enum FinanceContext {
    /// Gera um resumo factual (data de hoje + lista de lançamentos + totais)
    /// que servirá de base para a IA responder sobre os dados do usuário.
    static func build(from transactions: [Transaction], now: Date = .now) -> String {
        var lines: [String] = []
        lines.append("Data de hoje: \(Formatters.shortDate(now)).")
        lines.append("Moeda: Real brasileiro (R$).")

        if transactions.isEmpty {
            lines.append("Ainda não há lançamentos registrados.")
            return lines.joined(separator: "\n")
        }

        lines.append("Total de \(transactions.count) lançamento(s).")
        lines.append("Receitas somam \(Formatters.currency(transactions.totalIncome)); "
                     + "despesas somam \(Formatters.currency(transactions.totalExpense)); "
                     + "saldo geral \(Formatters.currency(transactions.balance)).")
        lines.append("")
        lines.append("Lançamentos (mais recentes primeiro):")

        let sorted = transactions.sorted { $0.date > $1.date }
        for t in sorted {
            let tipo: String
            if t.type == .expense {
                tipo = "Despesa/\(t.category?.label ?? "Sem categoria")"
            } else {
                tipo = "Receita"
            }
            lines.append("- \(Formatters.shortDate(t.date)) · \(tipo) · "
                         + "\(t.title) · \(Formatters.currency(t.amount))")
        }

        return lines.joined(separator: "\n")
    }

    /// Instruções (system prompt) que definem o comportamento da IA.
    static func systemPrompt(context: String) -> String {
        """
        Você é um assistente financeiro pessoal amigável dentro de um aplicativo \
        de finanças chamado "Meu Dinheiro". Responda sempre em português do \
        Brasil, de forma calma, acolhedora e sem julgamentos — o usuário quer \
        organizar suas finanças sem ansiedade. Use valores em Reais (R$).

        Baseie suas respostas exclusivamente nos dados abaixo. Se a informação \
        não estiver nos dados, diga isso com sinceridade em vez de inventar. \
        Seja objetivo e prático; quando fizer contas, mostre o resultado claro.

        DADOS DO USUÁRIO:
        \(context)
        """
    }
}
