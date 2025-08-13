//
//  RefreshControl.swift
//  SparkUp
//
//  Created by Diego on 11/7/25.
//


import SwiftUI

struct RefreshControl: View {
    @Binding var isRefreshing: Bool
    let action: () -> Void

    var body: some View {
        GeometryReader { geo in
            Color.clear
                .frame(height: 0)
                .onAppear {
                    if geo.frame(in: .global).minY > 50 && !isRefreshing {
                        isRefreshing = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            action()
                        }
                    }
                }
        }
    }
}
