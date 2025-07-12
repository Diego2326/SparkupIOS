import Foundation

struct Pedido: Identifiable, Decodable {
    var id: String = UUID().uuidString // Se asigna manualmente con el doc ID
    let nombreArticulo: String
    let correoComprador: String
    let correoVendedor: String
    let precio: Double
}
