//
//  IakadirApp.swift
//  Iakadir
//
//  Created by digital on 19/11/2025.
//

import SwiftUI

@main
struct IakadirApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var chatStore = ChatStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(chatStore)
        }
    }
}
