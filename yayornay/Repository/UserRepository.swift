//
//  UserViewModel.swift
//  yayornay
//
//  Created by Thomas Sickinger on 29.01.23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class UserRepository: ObservableObject {
    @Published var friends: [NamedUser] = []
    private let userCollection = Firestore.firestore().collection("user")
    private let friendRequestCollection = Firestore.firestore().collection("friendRequest")
    private let friendsPath = "friends"
    private var friendListener: ListenerRegistration?
    
    func add(_ user: NamedUser) {
        do {
            _ = try userCollection.document(user.id).setData(from: user)
        } catch {
            fatalError("Unable to add user: \(error.localizedDescription).")
        }
    }
    
    func addFriend(userId: String, friend: NamedUser) {
        do {
            _ = try userCollection.document(userId).collection(friendsPath).document(friend.id).setData(from: friend)
        } catch {
            fatalError("Unable to add user: \(error.localizedDescription).")
        }
    }
    
    func addFriendListener(userId: String) {
        self.friendListener = userCollection.document(userId).collection(friendsPath)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.friends = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: NamedUser.self)
                    } ?? []
                }
            }
    }
    
    func removeFriendsListener() {
        self.friendListener?.remove()
    }
    
    func sendFriendRequest(_ friendRequst: FriendRequest) {
        do {
            _ = try friendRequestCollection.addDocument(from: friendRequst)
        } catch {
            fatalError("Unable to add user: \(error.localizedDescription).")
        }
    }
}
