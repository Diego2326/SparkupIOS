//
//  ConfirmacionPedidoView.swift
//  SparkUp
//
//  Created by Diego on 10/7/25.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ConfirmacionPedidoView: View {
    let producto: Producto
    @Environment(\.dismiss) var dismiss
    @State private var enviando = false
    @State private var exito: Bool? = nil
    @AppStorage("isLoggedIn") var isLoggedIn = true

    var body: some View {
        VStack {
            if exito == true {
                Spacer()
                Text("¡Pedido enviado!")
                    .font(.title)
                Button("Volver al inicio") {
                    dismiss() // o navegar a MainView si usás NavigationStack
                }
                .padding()
                Spacer()
            } else {
                Spacer()
                Text("¿Confirmar compra de:")
                    .font(.title2)
                Text(producto.titulo)
                    .font(.title)
                    .padding(.top, 4)

                Text("Q\(producto.precio, specifier: "%.2f")")
                    .font(.title2)
                    .padding(.top, 2)

                Text("Vendedor: \(producto.vendedor)")
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)

                if enviando {
                    ProgressView("Enviando pedido...")
                        .padding()
                } else {
                    HStack(spacing: 16) {
                        Button("Confirmar") {
                            enviarPedido()
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Cancelar") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                    }
                }

                if exito == false {
                    Text("Ocurrió un error al enviar el pedido.")
                        .foregroundColor(.red)
                        .padding(.top, 8)
                }
                Spacer()
            }
        }
        .padding()
        .navigationTitle("Confirmación")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif

    }

    func enviarPedido() {
        guard let comprador = Auth.auth().currentUser?.email else {
            exito = false
            return
        }

        enviando = true
        let db = Firestore.firestore()

        let pedido: [String: Any] = [
            "nombreArticulo": producto.titulo,
            "correoComprador": comprador,
            "correoVendedor": producto.vendedor,
            "precio": producto.precio,
            "confirmado": false
        ]


        db.collection("pedidos").addDocument(data: pedido) { error in
            enviando = false
            if let error = error {
                print("Error al enviar pedido: \(error.localizedDescription)")
                exito = false
            } else {
                exito = true
            }
        }
    }
}
