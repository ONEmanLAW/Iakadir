//
//  ContentView.swift
//  Iakadir
//
//  Created by digital on 19/11/2025.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var hasStartedAuth = false

    var body: some View {
        NavigationStack {
            if let user = authViewModel.currentUser {
                HomeView(username: user.username)
                    .environmentObject(authViewModel)
            } else if hasStartedAuth {
                LoginView(onBack: {
                    hasStartedAuth = false
                })
                .environmentObject(authViewModel)
            } else {
                OnboardingView(onStart: {
                    hasStartedAuth = true
                })
                .environmentObject(authViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}



