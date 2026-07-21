import SwiftUI

/// Estilo visual compartilhado do app: fundo das telas e aparência dos cartões.
/// Centralizar aqui mantém as telas consistentes e fáceis de ajustar.
enum Theme {
    static let cornerRadius: CGFloat = 20

    /// Fundo padrão das telas: cor de agrupamento do sistema com um leve
    /// toque do verde de destaque no topo. Funciona em modo claro e escuro.
    static var screenBackground: some View {
        Color(.systemGroupedBackground)
            .overlay(
                LinearGradient(
                    colors: [Color.accentColor.opacity(0.10), .clear],
                    startPoint: .top,
                    endPoint: .center
                )
            )
            .ignoresSafeArea()
    }
}

/// Cartão padrão: fundo elevado, cantos arredondados e sombra bem suave.
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                Color(.secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: Theme.cornerRadius)
            )
            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}

extension View {
    /// Aplica o estilo de cartão padrão do app.
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
