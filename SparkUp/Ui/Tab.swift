//
//  Tab.swift
//  SparkUp
//
//  Created by Diego on 15/7/25.
//


enum Tab: String, CaseIterable, Identifiable {
    case inicio, pedidos, vender

    var id: String { rawValue }

    var title: String {
        switch self {
        case .inicio: return "Productos"
        case .pedidos: return "Pedidos"
        case .vender: return "Vender"
        }
    }

    var icon: String {
        switch self {
        case .inicio: return "house"
        case .pedidos: return "cart"
        case .vender: return "plus.circle"
        }
    }
}
