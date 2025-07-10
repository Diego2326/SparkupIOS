import SwiftUI

struct ProductCard: View {
    let producto: Producto
    let onClick: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: producto.imagenURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(height: 140)
            .clipped()
            .cornerRadius(16, corners: [.topLeft, .topRight])

            VStack(alignment: .leading, spacing: 4) {
                Text(producto.titulo)
                    .font(.headline)
                    .lineLimit(1)

                Text(producto.descripcion)
                    .font(.subheadline)
                    .lineLimit(2)

                Text("Q\(producto.precio, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.blue)

                Text("Publicado por: \(producto.vendedor)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding([.horizontal, .bottom])
        }
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .onTapGesture {
            onClick()
        }
    }
}
