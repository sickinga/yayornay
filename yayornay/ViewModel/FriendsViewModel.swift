//
//  FriendsViewModel.swift
//  yayornay
//
//  Created by Thomas Sickinger on 01.02.23.
//

import Foundation
import FirebaseAuth

class FriendsViewModel: ObservableObject {
    private var userRepository: UserRepository = UserRepository()
    @Published var searchString: String = ""
    @Published var isFriendView = true
    @Published var filteredFriends: [NamedUser] = []
    @Published var allFriends: [NamedUser] = []
    var friends: [NamedUser] {
        filteredFriends.isEmpty && searchString.isEmpty ? allFriends : filteredFriends
    }
    var friendRequests: [FriendRequest] {
        searchString.isEmpty ? userRepository.friendRequests :
            userRepository.friendRequests.filter { request in
                request.fromName.contains(searchString)
            }
    }
    var myFriendRequests: [FriendRequest] {
        userRepository.myFriendRequests
    }
    var filteredUsers: [NamedUser] {
        userRepository.filteredUsers
    }
    var showFriendList: Bool {
        !friends.isEmpty && (!searchString.isEmpty || isFriendView)
    }
    var showNoFriendsHint: Bool {
        friends.isEmpty && searchString.isEmpty && isFriendView
    }
    var showFriendRequestList: Bool {
        !friendRequests.isEmpty && (!searchString.isEmpty || !isFriendView)
    }
    var showNoFriendRequestsHint: Bool {
        userRepository.friendRequests.isEmpty && searchString.isEmpty && !isFriendView
    }
    var showMoreResultsList: Bool {
        !searchString.isEmpty && !userRepository.filteredUsers.isEmpty
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
    
    func sendFriendRequest(fromUser: User, toNamedUser: NamedUser) {
        let newRequest = FriendRequest(from: NamedUser(user: fromUser), to: toNamedUser)
        userRepository.sendFriendRequest(newRequest)
    }
    
    func searchFriends(_ searchString: String) {
        if searchString.isEmpty {
            filteredFriends = []
        } else {
            filteredFriends = userRepository.friends.filter {
                $0.name.lowercased().contains(searchString.lowercased())
            }
        }
        userRepository.search(searchString)
    }
    
    func removeFriend(_ friend: NamedUser) {
        userRepository.removeFriend(friend)
    }
    
    func answerFriendRequest(friendRequest: FriendRequest, accept: Bool) {
        userRepository.answerFriendRequest(friendRequest: friendRequest, accept: accept)
    }
}
