//
//  AstrologApp.swift
//  Astrolog
//
//  Created by Sergey on 19.09.2025.
//
import SwiftUI

@main
struct AstrologApp: App {
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(coordinator)
        }
    }
}
