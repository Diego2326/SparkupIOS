//
//  Producto.swift
//  SparkUp
//
//  Created by Diego on 10/7/25.
//


struct Producto: Identifiable, Codable, Hashable {
    var id: String
    var titulo: String
    var descripcion: String
    var precio: Double
    var imagenURL: String
    var vendedor: String
}

