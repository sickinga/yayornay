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
    @State private var searchString: String = ""
    @State private var isFriendView = true
    @State private var filteredFriends: [NamedUser] = []
    private var friends: [NamedUser] {
        filteredFriends.isEmpty && searchString.isEmpty ? userRepository.friends : filteredFriends
    }
    
    var body: some View {
        VStack {
            Picker("", selection: $isFriendView) {
                Text("Friends")
                    .tag(true)
                Text("Requests")
                    .tag(false)
            }.pickerStyle(SegmentedPickerStyle())
                .padding()
            if isFriendView {
                List {
                    ForEach(friends) { friend in
                        Text(friend.name)
                    }
                }.onAppear {
                    userRepository.addFriendListener(userId: authModel.user!.uid)
                }.onDisappear {
                    userRepository.removeFriendsListener()
                }.searchable(text: $searchString)
                .onChange(of: searchString, perform: { newValue in
                    if newValue.isEmpty {
                        filteredFriends = []
                    } else {
                        filteredFriends = userRepository.friends.filter { $0.name.lowercased().contains(searchString.lowercased())
                        }
                    }
                })
            } else {
                List {
                    ForEach(userRepository.friendRequests) { request in
                        HStack {
                            Text(request.fromName)
                            Spacer()
                            Button("ADD") {
                                userRepository.answerFriendRequest(friendRequest: request, accept: true)
                            }
                            Button("DENY") {
                                userRepository.answerFriendRequest(friendRequest: request, accept: false)
                            }
                        }.swipeActions {
                            Button {
                                userRepository.answerFriendRequest(friendRequest: request, accept: true)
                            } label: {
                                Label("ADD", systemImage: "checkmark.circle.fill")
                            }.tint(Color.green)
                            Button {
                                userRepository.answerFriendRequest(friendRequest: request, accept: false)
                            } label: {
                                Label("DENY", systemImage: "minus.circle.fill")
                            }
                            .tint(Color.red) }                    }
                }.onAppear {
                    userRepository.addFriendRequestListener(userId: authModel.user!.uid)
                }.onDisappear { userRepository.removeFriendRequestListener() }
            }
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
