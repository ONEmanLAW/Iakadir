//
//  IakadirApp.swift
//  Iakadir
//
//  Created by digital on 19/11/2025.
//

import SwiftUI

@main
struct IakadirApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
