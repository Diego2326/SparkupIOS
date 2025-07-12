import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI
import UIKit

struct VenderView: View {
    @AppStorage("isLoggedIn") var isLoggedIn = true
    @State private var nombre = ""
    @State private var descripcion = ""
    @State private var precio = ""
    @State private var vendedor = Auth.auth().currentUser?.email ?? ""
    
    @State private var image: UIImage?
    @State private var imageURL: URL?
    @State private var isUploading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showImagePicker = false
    @State private var useCamera = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Publicar nuevo producto")
                        .font(.title2)
                        .bold()

                    TextField("Nombre", text: $nombre)
                        .textFieldStyle(.roundedBorder)

                    TextField("Descripción", text: $descripcion)
                        .textFieldStyle(.roundedBorder)

                    TextField("Precio", text: $precio)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)

                    Button("Seleccionar desde galería") {
                        useCamera = false
                        showImagePicker = true
                    }

                    Button("Tomar foto") {
                        useCamera = true
                        showImagePicker = true
                    }

                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                    }

                    TextField("Vendedor", text: .constant(vendedor))
                        .textFieldStyle(.roundedBorder)
                        .disabled(true)

                    if isUploading {
                        ProgressView("Subiendo...")
                    } else {
                        Button("Publicar") {
                            publicarProducto()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
            .navigationTitle("Vender")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: useCamera ? .camera : .photoLibrary, selectedImage: $image)
            }
            .alert("Aviso", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    func publicarProducto() {
        guard !nombre.isEmpty, !descripcion.isEmpty, let precioDouble = Double(precio), let image = image else {
            alertMessage = "Completa todos los campos y selecciona una imagen."
            showAlert = true
            return
        }

        isUploading = true

        uploadToImgur(image: image) { imgurURL in
            guard let imgurURL = imgurURL else {
                alertMessage = "Error al subir imagen a Imgur."
                showAlert = true
                isUploading = false
                return
            }

            let producto: [String: Any] = [
                "titulo": nombre,
                "descripcion": descripcion,
                "precio": precioDouble,
                "imagenURL": imgurURL.absoluteString,
                "vendedor": vendedor
            ]

            Firestore.firestore().collection("producto").addDocument(data: producto) { error in
                isUploading = false
                if let error = error {
                    alertMessage = "Error al publicar: \(error.localizedDescription)"
                } else {
                    alertMessage = "Producto publicado correctamente."
                    nombre = ""
                    descripcion = ""
                    precio = ""
                    image = nil
                }
                showAlert = true
            }
        }
    }

    func uploadToImgur(image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: URL(string: "https://api.imgur.com/3/image")!)
        request.httpMethod = "POST"
        request.addValue("Client-ID 051aa459f066b21", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"foto.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n")

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataDict = json["data"] as? [String: Any],
               let link = dataDict["link"] as? String,
               let url = URL(string: link) {
                completion(url)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
