import SwiftUI

struct ProductCard: View {
    let producto: Producto
    let onClick: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GeometryReader { geo in
                AsyncImage(url: URL(string: producto.imagenURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.width)
                        .clipped()
                } placeholder: {
                    Color.gray.opacity(0.2)
                        .frame(width: geo.size.width, height: geo.size.width)
                }
            }
            .aspectRatio(1, contentMode: .fit)

            VStack(alignment: .leading, spacing: 4) {
                Text(producto.titulo)
                    .font(.headline)
                    .lineLimit(2)

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
            .padding(8)
        }
        .background(
            Group {
                #if os(iOS)
                Color(.systemGray6)
                #elseif os(macOS)
                Color(NSColor.controlBackgroundColor)
                #endif
            }
        )
        .cornerRadius(12)
        .onTapGesture {
            onClick()
        }
    }
}
