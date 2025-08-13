import Foundation

struct Pedido: Identifiable, Codable {
    var id: String = "" // <- importante para Firestore
    let nombreArticulo: String
    let correoComprador: String
    let correoVendedor: String
    let precio: Double
    var confirmado: Bool = false
}

extension Pedido {
    func withID(_ id: String) -> Pedido {
        return Pedido(
            id: id,
            nombreArticulo: self.nombreArticulo,
            correoComprador: self.correoComprador,
            correoVendedor: self.correoVendedor,
            precio: self.precio,
            confirmado: self.confirmado
        )
    }
}
