import SwiftUI
import FirebaseAuth

struct MainView: View {
    @AppStorage("isLoggedIn") var isLoggedIn = false
    let email = Auth.auth().currentUser?.email ?? "Sin email"

    var body: some View {
        VStack(spacing: 24) {
            Text("Bienvenido, \(email)")
                .font(.title)

            Button("Cerrar sesión") {
                do {
                    try Auth.auth().signOut()
                    isLoggedIn = false
                } catch {
                    print("Error al cerrar sesión: \(error.localizedDescription)")
                }
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}
