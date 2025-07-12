import SwiftUI
import FirebaseAuth

struct BottomBarView: View {
    @Binding var selectedTab: Int
    var onLogout: () -> Void

    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Inicio")
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
                .tag(0)

            Text("Pedidos")
                .tabItem {
                    Label("Pedidos", systemImage: "cart")
                }
                .tag(1)

            Text("Vender")
                .tabItem {
                    Label("Vender", systemImage: "plus.circle.fill")
                }
                .tag(2)

            Button(action: {
                onLogout()
            }) {
                Text("Cerrar sesión")
            }
            .tabItem {
                Label("Salir", systemImage: "arrow.backward.square")
            }
            .tag(3)
        }
        .tint(.blue)
    }
}
