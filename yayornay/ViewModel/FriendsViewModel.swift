//
//  FriendsViewModel.swift
//  yayornay
//
//  Created by Thomas Sickinger on 01.02.23.
//

import Foundation

class FriendsViewModel: ObservableObject {
    var userRepository: UserRepository = UserRepository()
    @Published var searchString: String = ""
    @Published var isFriendView = true
    @Published var filteredFriends: [NamedUser] = []
    @Published var allFriends: [NamedUser] = []
    var friends: [NamedUser] {
        filteredFriends.isEmpty && searchString.isEmpty ? allFriends : filteredFriends
    }
    var friendRequests: [FriendRequest] {
        userRepository.friendRequests
    }
    
    func initiate() {
        userRepository.addFriendListener { friends in
            self.allFriends = friends
        }
        userRepository.addFriendRequestListener()
    }
    
    func terminate() {
        userRepository.removeFriendsListener()
        userRepository.removeFriendsListener()
    }
}
