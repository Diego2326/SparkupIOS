//
//  AppDelegate.swift
//  SparkUp
//
//  Created by Diego on 15/7/25.
//


import SwiftUI
import FirebaseCore
#if os(macOS)
import AppKit
import GoogleSignIn
#endif


#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
#endif

@main
struct SparkUpApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    #else
    init() {
        FirebaseApp.configure()
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }
    }
    #endif

    @AppStorage("isLoggedIn") var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                MainView()
            } else {
                AuthView()
            }
        }
        #if os(macOS)
        .commands {
            CommandGroup(after: .sidebar) {
                Button("Recargar productos") {
                    NotificationCenter.default.post(name: .recargarProductos, object: nil)
                }
                .keyboardShortcut("r", modifiers: [.command])
            }
        }

        #endif
    }
}

