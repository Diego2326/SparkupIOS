struct Producto: Identifiable, Codable {
    var id: String
    var titulo: String
    var descripcion: String
    var precio: Double
    var imagenURL: String
    var vendedor: String
}
