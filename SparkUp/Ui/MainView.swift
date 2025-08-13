import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MainView: View {
    @AppStorage("isLoggedIn") var isLoggedIn = false
    let email = Auth.auth().currentUser?.email ?? "Sin email"

    @State private var productos: [Producto] = []
    @State private var selectedProducto: Producto? = nil
    @State private var loading = true
    @State private var soloMios = false
    @State private var mostrarError = false
    @State private var mensajeError = ""

    #if os(macOS)
    @State private var selectedTab: Tab = .inicio
    #else
    @State private var selectedIndex = 0
    #endif

    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            SidebarView(selectedTab: $selectedTab, isLoggedIn: $isLoggedIn)
        } detail: {
            NavigationStack {
                contentForTab(selectedTab)
                    .navigationDestination(item: $selectedProducto) { producto in
                        ProductoDetalleView(productoId: producto.id)
                    }
                    .navigationTitle(selectedTab.title)
                    .onAppear { setup() }
            }
            .alert("Error al cargar productos", isPresented: $mostrarError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(mensajeError)
            }
        }
        #else
        NavigationStack {
            VStack(spacing: 0) {
                switch selectedIndex {
                case 0:
                    contentView
                case 1:
                    PedidosView()
                case 2:
                    VenderView {
                        selectedIndex = 0
                        cargarProductos()
                    }
                default:
                    Text("Sección \(selectedIndex)")
                }

                BottomBarView(selectedIndex: $selectedIndex, isLoggedIn: $isLoggedIn)
            }
            .navigationTitle("Productos")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: cargarProductos)
            .navigationDestination(item: $selectedProducto) { producto in
                ProductoDetalleView(productoId: producto.id)
            }
            .alert("Error al cargar productos", isPresented: $mostrarError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(mensajeError)
            }
        }
        #endif
    }

    #if os(macOS)
    @ViewBuilder
    func contentForTab(_ tab: Tab) -> some View {
        switch tab {
        case .inicio:
            contentView
        case .pedidos:
            PedidosView()
        case .vender:
            VenderView {
                selectedTab = .inicio
                cargarProductos()
            }
        }
    }
    #endif

    var productosFiltrados: [Producto] {
        soloMios
            ? productos.filter { $0.vendedor == email }
            : productos
    }

    func cargarProductos() {
        loading = true
        Firestore.firestore().collection("producto").getDocuments { snapshot, error in
            if let error = error {
                loading = false
                mensajeError = "No se pudo obtener los productos.\n\(error.localizedDescription)"
                mostrarError = true
                return
            }

            guard let docs = snapshot?.documents else {
                loading = false
                mensajeError = "No se recibió respuesta del servidor."
                mostrarError = true
                return
            }

            productos = docs.compactMap { doc in
                var data = doc.data()
                data["id"] = doc.documentID
                do {
                    let json = try JSONSerialization.data(withJSONObject: data)
                    return try JSONDecoder().decode(Producto.self, from: json)
                } catch {
                    print("Error al decodificar producto: \(error)")
                    return nil
                }
            }

            loading = false
        }
    }

    var contentView: some View {
        VStack {
            Toggle("Mostrar solo mis productos", isOn: $soloMios)
                .padding(.horizontal)

            if loading {
                ProgressView("Cargando productos...")
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16, alignment: .top),
                            GridItem(.flexible(), spacing: 16, alignment: .top)
                        ],
                        spacing: 16
                    ) {
                        ForEach(productosFiltrados) { producto in
                            ProductCard(producto: producto) {
                                selectedProducto = producto
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                .refreshable {
                    cargarProductos()
                }
            }
        }
    }

    func setup() {
        cargarProductos()
        #if os(macOS)
        NotificationCenter.default.addObserver(forName: .recargarProductos, object: nil, queue: .main) { _ in
            cargarProductos()
        }
        #endif
    }
}

// MARK: - Notificación para Cmd + R

extension Notification.Name {
    static let recargarProductos = Notification.Name("recargarProductos")
}
