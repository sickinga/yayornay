//
//  yayornayApp.swift
//  yayornay
//
//  Created by Thomas Sickinger on 29.01.23.
//

import SwiftUI

@main
struct yayornayApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
