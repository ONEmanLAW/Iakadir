//
//  ContentView.swift
//  Iakadir
//
//  Created by digital on 19/11/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.primaryPurple
                .ignoresSafeArea()

            Text("Bienvenue dans Iakadir")
                .foregroundColor(.appWhite)
                .font(.title)
        }
    }
}

#Preview {
    ContentView()
}
