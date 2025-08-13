import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProductoDetalleView: View {
    let productoId: String
    @Environment(\.dismiss) var dismiss
    @AppStorage("isLoggedIn") var isLoggedIn = true

    @State private var producto: Producto?
    @State private var loading = true
    @State private var showDeleteDialog = false
    @State private var errorMessage: String?
    @State private var mostrarSnackbar = false
    @State private var volverAMain = false
    @State private var productoAConfirmar: Producto? = nil

    var body: some View {
        NavigationStack {
            Group {
                if loading {
                    ProgressView("Cargando...")
                } else if let producto = producto {
                    ScrollView {
                        VStack(spacing: 16) {
                            GeometryReader { geo in
                                AsyncImage(url: URL(string: producto.imagenURL)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geo.size.width - 32, height: geo.size.width - 32)
                                        .clipped()
                                        .cornerRadius(16)
                                } placeholder: {
                                    Color.gray
                                        .frame(width: geo.size.width - 32, height: geo.size.width - 32)
                                        .cornerRadius(16)
                                }
                                .padding(.horizontal, 16)
                            }
                            .frame(height: 300) // Ajustamos altura para que funcione GeometryReader


                            Text(producto.titulo)
                                .font(.title)
                                .bold()

                            Text(producto.descripcion)
                                .font(.body)

                            Text("Q\(producto.precio, specifier: "%.2f")")
                                .font(.title2)
                                .foregroundColor(.blue)

                            Text("Publicado por: \(producto.vendedor)")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            if esMio(producto) {
                                Text("Este es tu producto.")
                                    .foregroundColor(.red)

                                Button("Eliminar producto") {
                                    showDeleteDialog = true
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.red)
                            } else {
                                Button("Comprar") {
                                    productoAConfirmar = producto
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding()
                    }

                } else {
                    Text("Producto no encontrado")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Detalle del producto")
           
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onAppear { cargarProducto() }
            .alert("Aviso", isPresented: $mostrarSnackbar) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
            .confirmationDialog("¿Eliminar producto?",
                isPresented: $showDeleteDialog,
                titleVisibility: .visible
            ) {
                Button("Eliminar", role: .destructive) {
                    eliminarProducto()
                }
                Button("Cancelar", role: .cancel) {}
            }
            // ✅ Redirección a ConfirmacionPedidoView usando navigationDestination
            .navigationDestination(item: $productoAConfirmar) { producto in
                ConfirmacionPedidoView(producto: producto)
            }
            // ✅ Redirección a MainView al eliminar
            .navigationDestination(isPresented: $volverAMain) {
                MainView()
            }
        }
    }

    func cargarProducto() {
        loading = true
        Firestore.firestore().collection("producto").document(productoId).getDocument { docSnapshot, error in
            if let data = docSnapshot?.data() {
                var datos = data
                datos["id"] = productoId
                do {
                    let json = try JSONSerialization.data(withJSONObject: datos)
                    self.producto = try JSONDecoder().decode(Producto.self, from: json)
                } catch {
                    self.errorMessage = "Error al decodificar producto"
                    self.mostrarSnackbar = true
                }
            }
            loading = false
        }
    }

    func eliminarProducto() {
        Firestore.firestore().collection("producto").document(productoId).delete { error in
            if let error = error {
                errorMessage = "Error al eliminar: \(error.localizedDescription)"
                mostrarSnackbar = true
            } else {
                errorMessage = "Producto eliminado"
                mostrarSnackbar = true
                volverAMain = true
            }
        }
    }

    func esMio(_ producto: Producto) -> Bool {
        let user = Auth.auth().currentUser
        return user?.email == producto.vendedor
    }
}
