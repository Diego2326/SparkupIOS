//
//  RootView.swift
//  SparkUp
//
//  Created by Diego on 15/7/25.
//


import SwiftUI

struct RootView: View {
    @AppStorage("isLoggedIn") var isLoggedIn = false

    var body: some View {
        Group {
            if isLoggedIn {
                MainView()
            } else {
                AuthView()
            }
        }
    }
}
