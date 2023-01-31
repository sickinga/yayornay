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
    @Published var friendRequests: [FriendRequest] = []
    @Published var filteredUsers: [NamedUser] = []
    private let userCollection = Firestore.firestore().collection("user")
    private let friendRequestCollection = Firestore.firestore().collection("friendRequest")
    private let friendsPath = "friends"
    private var friendListener: ListenerRegistration?
    private var friendRequestListener: ListenerRegistration?
    
    func add(_ user: NamedUser) {
        print(user)
        do {
            _ = try userCollection.document(user.id).setData(from: user)
            userCollection.document(user.id).updateData(["keywordsForLookup": user.keywordsForLookup])
        } catch {
            fatalError("Unable to add user: \(error.localizedDescription).")
        }
    }
    
    func search(_ searchString: String) {
        userCollection.whereField("keywordsForLookup", arrayContains: searchString)
            .getDocuments { querySnapshot, error in
                guard let documents = querySnapshot?.documents, error == nil else {
                    print("No documents")
                    return
                }
                self.filteredUsers = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: NamedUser.self)
                }
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
            _ = try friendRequestCollection.document(friendRequst.id).setData(from: friendRequst)
        } catch {
            fatalError("Unable to add friend request: \(error.localizedDescription).")
        }
    }
    
    func answerFriendRequest(friendRequest: FriendRequest, accept: Bool) {
        self.friendRequestCollection.document(friendRequest.id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
                return
            }
            if accept {
                self.addFriend(userId: friendRequest.to, friend: NamedUser(id: friendRequest.from, name: friendRequest.fromName))
                self.addFriend(userId: friendRequest.from, friend: NamedUser(id: friendRequest.to, name: friendRequest.toName))
            }
        }
    }
    
    func addFriendRequestListener(userId: String) {
        self.friendRequestListener = friendRequestCollection.whereField("to", isEqualTo: userId)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.friendRequests = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: FriendRequest.self)
                    } ?? []
                }
            }
    }
    
    func removeFriendRequestListener() {
        self.friendRequestListener?.remove()
    }
}
