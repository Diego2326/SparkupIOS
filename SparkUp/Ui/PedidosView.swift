import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PedidosView: View {
    @State private var tabIndex = 0
    @State private var pedidosComprador: [Pedido] = []
    @State private var pedidosVendedor: [Pedido] = []
    @State private var loading = true
    @State private var refrescando = false

    let email = Auth.auth().currentUser?.email ?? "Desconocido"

    var body: some View {
        VStack {
            Picker("Tipo", selection: $tabIndex) {
                Text("Como comprador").tag(0)
                Text("Como vendedor").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if loading && !refrescando {
                Spacer()
                ProgressView("Cargando...")
                Spacer()
            } else {
                ScrollView {
                    RefreshControl(isRefreshing: $refrescando) {
                        cargarPedidos()
                    }

                    if tabIndex == 0 {
                        PedidoListView(
                            pedidos: pedidosComprador,
                            emptyMsg: "No tienes pedidos como comprador.",
                            onCancelar: eliminarPedido
                        )
                    } else {
                        PedidoListView(
                            pedidos: pedidosVendedor,
                            emptyMsg: "No tienes pedidos como vendedor."
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
        refrescando = true
        let db = Firestore.firestore()

        db.collection("pedidos").whereField("correoComprador", isEqualTo: email)
            .getDocuments { snap, _ in
                pedidosComprador = snap?.documents.compactMap {
                    try? $0.data(as: Pedido.self).withID($0.documentID)
                } ?? []
            }

        db.collection("pedidos").whereField("correoVendedor", isEqualTo: email)
            .getDocuments { snap, _ in
                pedidosVendedor = snap?.documents.compactMap {
                    try? $0.data(as: Pedido.self).withID($0.documentID)
                } ?? []
                loading = false
                refrescando = false
            }
    }

    func eliminarPedido(_ id: String) {
        let db = Firestore.firestore()
        db.collection("pedidos").document(id).delete { _ in
            cargarPedidos()
        }
    }
}
