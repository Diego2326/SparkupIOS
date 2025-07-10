import SwiftUI
import Firebase
import GoogleSignIn
import GoogleSignInSwift

struct AuthView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()

                Image("logosparkup")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)

                TextField("Correo Electrónico", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)

                SecureField("Contraseña", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("¿Olvidaste tu contraseña?") {
                    alertMessage = "Función no disponible todavía"
                    showingAlert = true
                }
                .font(.footnote)
                .foregroundColor(.blue)

                Button("Iniciar Sesión") {
                    signInWithEmail()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

                GoogleSignInButton {
                    signInWithGoogle()
                }
                .frame(height: 50)
                .padding(.top)

                Toggle("Modo oscuro", isOn: $isDarkMode)
                    .padding(.top)

                Spacer()

                NavigationLink("¿No tienes cuenta? Regístrate", destination: RegisterView())
                    .font(.footnote)
            }
            .padding()
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func signInWithEmail() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = "Inicio de sesión fallido: \(error.localizedDescription)"
                showingAlert = true
            } else {
                // Ir a Home
            }
        }
    }

    private func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else { return }

        GIDSignIn.sharedInstance.signIn(with: config, presenting: rootViewController) { user, error in
            if let error = error {
                alertMessage = "No se pudo iniciar sesión con Google: \(error.localizedDescription)"
                showingAlert = true
                return
            }

            guard let idToken = user?.authentication.idToken,
                  let accessToken = user?.authentication.accessToken else {
                alertMessage = "No se pudo obtener credenciales de Google."
                showingAlert = true
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    alertMessage = "Error con Firebase: \(error.localizedDescription)"
                    showingAlert = true
                } else {
                    // Ir a Home
                }
            }
        }
    }
}
