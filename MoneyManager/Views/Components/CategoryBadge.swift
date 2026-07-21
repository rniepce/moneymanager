import SwiftUI

/// Selo circular com ícone colorido, usado nas listas e no resumo.
struct CategoryBadge: View {
    let systemImage: String
    let color: Color

    var body: some View {
        Image(systemName: systemImage)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(color)
            .frame(width: 36, height: 36)
            .background(color.opacity(0.15), in: Circle())
    }
}

#Preview {
    HStack {
        CategoryBadge(systemImage: "cart.fill", color: .green)
        CategoryBadge(systemImage: "car.fill", color: .blue)
    }
    .padding()
}
