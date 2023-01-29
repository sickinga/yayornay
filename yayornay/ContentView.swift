//
//  ContentView.swift
//  yayornay
//
//  Created by Thomas Sickinger on 29.01.23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject private var authModel: AuthViewModel
    
    var body: some View {
        Group {
            if authModel.user != nil {
                MainView()
            } else {
                LoginView()
            }
        }.onAppear {
            authModel.listenToAuthState()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
