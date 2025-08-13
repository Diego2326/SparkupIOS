import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI

#if os(iOS)
import UIKit
typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
typealias PlatformImage = NSImage
#endif

struct VenderView: View {
    @AppStorage("isLoggedIn") var isLoggedIn = true
    var onPublicado: () -> Void = {}

    @State private var nombre = ""
    @State private var descripcion = ""
    @State private var precio = ""
    @State private var vendedor = Auth.auth().currentUser?.email ?? ""

    @State private var image: PlatformImage? = nil
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isUploading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showCameraPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Publicar nuevo producto")
                        .font(.title2).bold()

                    Group {
                        TextField("Nombre", text: $nombre)
                        TextField("Descripción", text: $descripcion)
                        
                        #if os(iOS)
                        TextField("Precio", text: $precio)
                            .keyboardType(.decimalPad)
                        #else
                        TextField("Precio", text: $precio)
                        #endif
                    }

                    .textFieldStyle(.roundedBorder)

                    HStack(spacing: 12) {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Label("Galería", systemImage: "photo")
                        }

                        Button {
                            #if os(iOS)
                            showCameraPicker = true
                            #elseif os(macOS)
                            let panel = NSOpenPanel()
                            panel.allowedContentTypes = [.image]
                            panel.allowsMultipleSelection = false
                            panel.canChooseDirectories = false
                            if panel.runModal() == .OK, let url = panel.url,
                               let nsImage = NSImage(contentsOf: url) {
                                image = cropToSquare(nsImage)
                            }
                            #endif
                        } label: {
                            #if os(iOS)
                            Label("Cámara", systemImage: "camera")
                            #elseif os(macOS)
                            Label("Finder", systemImage: "folder")
                            #endif
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    if let image = image {
                        GeometryReader { geo in
                            let width = geo.size.width - 32

                            let displayedImage: Image = {
                                #if os(iOS)
                                return Image(uiImage: image)
                                #elseif os(macOS)
                                return Image(nsImage: image)
                                #endif
                            }()

                            displayedImage
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .frame(width: width, height: width)
                                .clipped()
                                .cornerRadius(12)
                                .padding(.horizontal, 16)
                        }
                        .frame(height: 300)
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
            .alert("Aviso", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            #if os(iOS)
            .sheet(isPresented: $showCameraPicker) {
                ImagePicker(sourceType: .camera) { selected in
                    if let selected = selected {
                        self.image = cropToSquare(selected)
                    }
                }
            }
            #endif
            .modifier(SelectedItemChangeModifier(selectedItem: $selectedItem, image: $image))
        }
    }

    func cropToSquare(_ image: PlatformImage) -> PlatformImage {
        #if os(iOS)
        let length = min(image.size.width, image.size.height)
        let x = (image.size.width - length) / 2
        let y = (image.size.height - length) / 2
        let cropRect = CGRect(x: x, y: y, width: length, height: length)

        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }

        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        #elseif os(macOS)
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return image
        }

        let length = min(cgImage.width, cgImage.height)
        let x = (cgImage.width - length) / 2
        let y = (cgImage.height - length) / 2
        let cropRect = CGRect(x: x, y: y, width: length, height: length)

        guard let cropped = cgImage.cropping(to: cropRect) else {
            return image
        }

        return NSImage(cgImage: cropped, size: NSSize(width: length, height: length))
        #endif
    }

    func publicarProducto() {
        guard !nombre.isEmpty,
              !descripcion.isEmpty,
              Double(precio) != nil,
              let image = image else {
            alertMessage = "Completa todos los campos y selecciona una imagen."
            showAlert = true
            return
        }

        isUploading = true

        #if os(iOS)
        guard let img = image.jpegData(compressionQuality: 0.8) else {
            alertMessage = "No se pudo convertir la imagen."
            showAlert = true
            isUploading = false
            return
        }
        uploadToImgur(imageData: img)
        #elseif os(macOS)
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmap.representation(using: .jpeg, properties: [:]) else {
            alertMessage = "No se pudo convertir la imagen."
            showAlert = true
            isUploading = false
            return
        }
        uploadToImgur(imageData: jpegData)
        #endif
    }

    func uploadToImgur(imageData: Data) {
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

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                self.isUploading = false
                guard let data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let dataDict = json["data"] as? [String: Any],
                      let link = dataDict["link"] as? String,
                      let url = URL(string: link) else {
                    self.alertMessage = "Error al subir imagen a Imgur."
                    self.showAlert = true
                    return
                }

                let producto: [String: Any] = [
                    "titulo": nombre,
                    "descripcion": descripcion,
                    "precio": Double(precio) ?? 0.0,
                    "imagenURL": url.absoluteString,
                    "vendedor": vendedor
                ]

                Firestore.firestore().collection("producto").addDocument(data: producto) { error in
                    if let error = error {
                        alertMessage = "Error al publicar: \(error.localizedDescription)"
                    } else {
                        alertMessage = "Producto publicado correctamente."
                        nombre = ""
                        descripcion = ""
                        precio = ""
                        self.image = nil
                        onPublicado()
                    }
                    showAlert = true
                }
            }
        }.resume()
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

// MARK: - ViewModifier para onChange compatible iOS 16 y 17
struct SelectedItemChangeModifier: ViewModifier {
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var image: PlatformImage?

    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 17, *) {
            content.onChange(of: selectedItem, initial: false) { _, newValue in
                handle(newValue)
            }
        } else {
            content.onChange(of: selectedItem) { newValue in
                handle(newValue)
            }
        }
        #else
        content // En macOS no hay PhotosPicker, así que no hacemos nada
        #endif
    }

    #if os(iOS)
    private func handle(_ newItem: PhotosPickerItem?) {
        guard let newItem = newItem else { return }
        Task {
            if let data = try? await newItem.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                image = cropToSquare(uiImage)
            }
        }
    }

    private func cropToSquare(_ image: UIImage) -> UIImage {
        let length = min(image.size.width, image.size.height)
        let x = (image.size.width - length) / 2
        let y = (image.size.height - length) / 2
        let cropRect = CGRect(x: x, y: y, width: length, height: length)
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    #endif
}
