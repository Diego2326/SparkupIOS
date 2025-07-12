import SwiftUI

struct PedidoListView: View {
    let pedidos: [Pedido]
    let emptyMsg: String
    var onCancelar: ((String) -> Void)? = nil

    var body: some View {
        if pedidos.isEmpty {
            Text(emptyMsg)
                .foregroundColor(.secondary)
                .padding()
        } else {
            VStack(spacing: 12) {
                ForEach(pedidos) { pedido in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Artículo: \(pedido.nombreArticulo)")
                        Text("Precio: Q\(pedido.precio, specifier: "%.2f")")
                        Text("Comprador: \(pedido.correoComprador)")
                        Text("Vendedor: \(pedido.correoVendedor)")

                        if let onCancelar = onCancelar {
                            Button("Cancelar pedido") {
                                onCancelar(pedido.id)
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}
