import SwiftUI
import SwiftData

@main
struct MoneyManagerApp: App {
    /// Container do SwiftData com persistência local no aparelho.
    let container: ModelContainer = {
        do {
            return try ModelContainer(for: Transaction.self)
        } catch {
            fatalError("Não foi possível iniciar o armazenamento local: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.locale, Formatters.ptBR)
        }
        .modelContainer(container)
    }
}
