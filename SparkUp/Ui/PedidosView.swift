import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PedidosView: View {
    @State private var tabIndex = 0
    @State private var pedidosComprador: [Pedido] = []
    @State private var pedidosVendedor: [Pedido] = []
    @State private var loading = true

    var email: String {
        Auth.auth().currentUser?.email ?? "desconocido"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Tipo", selection: $tabIndex) {
                    Text("Como comprador").tag(0)
                    Text("Como vendedor").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if loading {
                    VStack {
                        Spacer()
                        ProgressView("Cargando...")
                        Spacer()
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    if tabIndex == 0 {
                        PedidoListView(
                            pedidos: pedidosComprador,
                            emptyMsg: "No tienes pedidos como comprador.",
                            esVendedor: false,
                            onConfirmar: { _ in },
                            onCancelar: eliminarPedido,
                            onRefresh: cargarPedidos
                        )
                    } else {
                        PedidoListView(
                            pedidos: pedidosVendedor,
                            emptyMsg: "No tienes pedidos como vendedor.",
                            esVendedor: true,
                            onConfirmar: confirmarPedido,
                            onCancelar: nil,
                            onRefresh: cargarPedidos
                        )
                    }
                }
            }
        }
        .navigationTitle("Mis pedidos")
        .onAppear(perform: cargarPedidos)
    }

    func cargarPedidos() {
        loading = true
        let db = Firestore.firestore()
        let group = DispatchGroup()

        group.enter()
        db.collection("pedidos")
            .whereField("correoComprador", isEqualTo: email)
            .getDocuments { snap, error in
                defer { group.leave() }
                pedidosComprador = snap?.documents.compactMap {
                    try? $0.data(as: Pedido.self).withID($0.documentID)
                } ?? []
                print("📦 pedidosComprador: \(pedidosComprador.count)")
                if let error = error {
                    print("❌ Error cargando comprador: \(error)")
                }
            }

        group.enter()
        db.collection("pedidos")
            .whereField("correoVendedor", isEqualTo: email)
            .getDocuments { snap, error in
                defer { group.leave() }
                pedidosVendedor = snap?.documents.compactMap {
                    try? $0.data(as: Pedido.self).withID($0.documentID)
                } ?? []
                print("📦 pedidosVendedor: \(pedidosVendedor.count)")
                if let error = error {
                    print("❌ Error cargando vendedor: \(error)")
                }
            }

        group.notify(queue: .main) {
            loading = false
            print("✅ Pedidos cargados")
        }
    }

    func eliminarPedido(_ id: String) {
        Firestore.firestore().collection("pedidos").document(id).delete { _ in
            cargarPedidos()
        }
    }

    func confirmarPedido(_ id: String) {
        Firestore.firestore().collection("pedidos").document(id).updateData([
            "confirmado": true
        ]) { _ in
            cargarPedidos()
        }
    }
}
