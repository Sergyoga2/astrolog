//
//  AstrologApp.swift
//  Astrolog
//
//  Created by Sergey on 19.09.2025.
//
import SwiftUI
import Firebase

@main
struct AstrologApp: App {
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var firebaseService = FirebaseService.shared
    @StateObject private var dataRepository = DataRepository.shared

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(coordinator)
                .environmentObject(firebaseService)
                .environmentObject(dataRepository)
        }
    }
}
