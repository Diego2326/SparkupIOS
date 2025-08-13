import SwiftUI

struct PedidoListView: View {
    let pedidos: [Pedido]
    let emptyMsg: String
    let esVendedor: Bool
    var onConfirmar: (String) -> Void = { _ in }
    var onCancelar: ((String) -> Void)? = nil
    var onRefresh: (() -> Void)? = nil

    var body: some View {
        if pedidos.isEmpty {
            Text(emptyMsg)
                .foregroundColor(.secondary)
                .padding()
        } else {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(pedidos) { pedido in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Artículo: \(pedido.nombreArticulo)")
                            Text("Precio: Q\(pedido.precio, specifier: "%.2f")")
                            Text("Comprador: \(pedido.correoComprador)")
                            Text("Vendedor: \(pedido.correoVendedor)")

                            if esVendedor {
                                if pedido.confirmado {
                                    Text("Pedido confirmado ✅")
                                        .foregroundColor(.green)
                                } else {
                                    Button("Confirmar pedido") {
                                        onConfirmar(pedido.id)
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            } else {
                                if pedido.confirmado {
                                    Text("Pedido confirmado ✅")
                                        .foregroundColor(.green)
                                } else if let onCancelar = onCancelar {
                                    Button("Cancelar pedido") {
                                        onCancelar(pedido.id)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.red)
                                }
                            }
                        }
                        .padding()
                        .background(backgroundColor)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .refreshable {
                onRefresh?()
            }
        }
    }
    var backgroundColor: Color {
        #if os(iOS)
        return Color(UIColor.systemGray6)
        #else
        return Color.gray.opacity(0.1)
        #endif
    }

}
