import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif


struct AuthView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @Environment(\.colorScheme) var colorScheme

    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showResetSheet = false
    @State private var resetEmail = ""

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                VStack(spacing: 20) {
                    Spacer(minLength: 60)

                    Image("logosparkup")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300, maxHeight: 180)

                    TextField("Correo Electrónico", text: $email)
                        .textFieldStyle(.roundedBorder)
                    #if os(iOS)
                        .keyboardType(.emailAddress)
                    #endif

                    SecureField("Contraseña", text: $password)
                        .textFieldStyle(.roundedBorder)

                    Button("¿Olvidaste la contraseña?") {
                        showResetSheet = true
                    }
                    .font(.footnote)
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .sheet(isPresented: $showResetSheet) {
                        VStack(spacing: 20) {
                            Text("Recuperar contraseña")
                                .font(.title2)
                                .bold()

                            TextField("Correo Electrónico", text: $resetEmail)
                                .textFieldStyle(.roundedBorder)
                            #if os(iOS)
                                .keyboardType(.emailAddress)
                            #endif

                            Button("Enviar correo de recuperación") {
                                enviarCorreoReset()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)

                            Button("Cerrar") {
                                showResetSheet = false
                            }
                            .foregroundColor(.red)

                            Spacer()
                        }
                        .padding()
                        .presentationDetents([.medium])
                    }

                    Button("Iniciar Sesión") {
                        signInWithEmail()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                    Button(action: {
                        signInWithGoogle()
                    }) {
                        Image("GoogleButton")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 48)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(8)
                    }

                    Spacer()

                    NavigationLink("¿No tienes cuenta? Regístrate") {
                        Text("Registro View") // <- cámbialo luego por tu vista real
                    }
                    .font(.footnote)
                    .foregroundColor(.accentColor)
                }
                .padding()
                .frame(maxWidth: 420)
                .alert("Aviso", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(alertMessage)
                }
            }
        }
    }

    private func signInWithEmail() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = "Error al iniciar sesión: \(error.localizedDescription)"
                showingAlert = true
            } else {
                isLoggedIn = true
            }
        }
    }

    private func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            alertMessage = "No se encontró clientID de Firebase"
            showingAlert = true
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

    #if os(iOS)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            alertMessage = "No se pudo obtener el rootViewController"
            showingAlert = true
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            handleGoogleResult(result, error)
        }
    #elseif os(macOS)
        guard let window = NSApplication.shared.windows.first else {
            alertMessage = "No se pudo obtener la ventana principal."
            showingAlert = true
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: window) { result, error in
            handleGoogleResult(result, error)
        }

    #endif
    }
    private func handleGoogleResult(_ result: GIDSignInResult?, _ error: Error?) {
        if let error = error {
            alertMessage = "Error al iniciar con Google: \(error.localizedDescription)"
            showingAlert = true
            return
        }

        guard let user = result?.user,
              let idToken = user.idToken?.tokenString else {
            alertMessage = "No se pudo obtener credenciales de Google"
            showingAlert = true
            return
        }

        let accessToken = user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                alertMessage = "Error con Firebase: \(error.localizedDescription)"
                showingAlert = true
            } else {
                isLoggedIn = true
            }
        }
    }

    private func enviarCorreoReset() {
        let trimmedEmail = resetEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedEmail.isEmpty else {
            alertMessage = "Por favor ingresa tu correo electrónico."
            showingAlert = true
            return
        }

        guard isValidEmail(trimmedEmail) else {
            alertMessage = "El correo ingresado no es válido."
            showingAlert = true
            return
        }

        Auth.auth().sendPasswordReset(withEmail: trimmedEmail) { error in
            if let error = error {
                alertMessage = "Error al enviar correo: \(error.localizedDescription)"
            } else {
                alertMessage = "Correo de recuperación enviado a \(trimmedEmail)"
                showResetSheet = false
            }
            showingAlert = true
        }
    }
    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^\S+@\S+\.\S+$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

}

