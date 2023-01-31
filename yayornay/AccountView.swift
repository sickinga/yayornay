//
//  AccountView.swift
//  yayornay
//
//  Created by Thomas Sickinger on 31.01.23.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var authModel: AuthViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 128, height: 128)
                .padding(.top, 25)
                .foregroundColor(.blue)
            Text(authModel.user?.displayName ?? "")
                .font(.title)
                .padding()
            List {
                Button(action: {print("log out") }) {
                    Text("Change name")
                        .font(.callout)
                }
                Button(action: { authModel.signOut() }) {
                    Text("Sign out")
                        .font(.callout)
                        .bold()
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AccountView()
                .environmentObject(AuthViewModel())
        }
    }
}
