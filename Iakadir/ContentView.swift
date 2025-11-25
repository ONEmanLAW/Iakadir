//
//  ContentView.swift
//  Iakadir
//
//  Created by digital on 19/11/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var chatStore = ChatStore()
    @State private var hasStartedAuth = false

    var body: some View {
        NavigationStack {
            if let user = authViewModel.currentUser {
                HomeView(username: user.username)
            } else if hasStartedAuth {
                LoginView(onBack: {
                    hasStartedAuth = false
                })
            } else {
                OnboardingView(onStart: {
                    hasStartedAuth = true
                })
            }
        }
        
        .environmentObject(authViewModel)
        .environmentObject(chatStore)
    }
}

#Preview {
    ContentView()
}


