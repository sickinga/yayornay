//
//  FriendsView.swift
//  yayornay
//
//  Created by Thomas Sickinger on 30.01.23.
//

import SwiftUI

struct FriendsView: View {
    @EnvironmentObject private var authModel: AuthViewModel
    @StateObject var userRepository: UserRepository = UserRepository()
    @State private var search: String = ""
    
    var body: some View {
        VStack {
            TextField("Search", text: $search)
                .textFieldStyle(.roundedBorder)
                .padding()
            List {
                ForEach(userRepository.friends) { friend in
                    Text(friend.name)
                }
            }.onAppear {
                userRepository.addFriendListener(userId: authModel.user!.uid)
            }.onDisappear { userRepository.removeFriendsListener() }
        }.toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(
                    action: {
                        authModel.signOut()
                    },
                    label: {
                        Text("Sign Out")
                            .bold()
                    }
                )
            }
        }
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
