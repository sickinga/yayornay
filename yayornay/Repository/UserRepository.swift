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
    @Published var myFriendRequests: [FriendRequest] = []
    @Published var filteredUsers: [NamedUser] = []
    private let userCollection = Firestore.firestore().collection("user")
    private let friendRequestCollection = Firestore.firestore().collection("friendRequest")
    private let friendsPath = "friends"
    private var friendListener: ListenerRegistration?
    private var friendRequestToListener: ListenerRegistration?
    private var myFriendRequestListener: ListenerRegistration?
    private var allUsers: [NamedUser] = []
    
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
        userCollection.whereField("keywordsForLookup", arrayContains: searchString.lowercased())
            .getDocuments { querySnapshot, error in
                guard let documents = querySnapshot?.documents, error == nil else {
                    print("No documents")
                    return
                }
                self.allUsers = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: NamedUser.self)
                }
                self.filterUsers()
            }
    }
    
    func filterUsers() {
        self.filteredUsers = self.allUsers.filter { user in
            !self.friends.contains { friend in
                friend.id == user.id
            } &&
            !self.friendRequests.contains { request in
                request.from == user.id
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
    
    func removeFriend(_ friend: NamedUser) {
        userCollection.document(CurrentUser.uid).collection(friendsPath).document(friend.id).delete()
        userCollection.document(friend.id).collection(friendsPath).document(CurrentUser.uid).delete()
    }
    
    func addFriendListener(completion: @escaping ([NamedUser]) -> Void) {
        self.friendListener = userCollection.document(CurrentUser.uid).collection(friendsPath)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.friends = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: NamedUser.self)
                    } ?? []
                    completion(self.friends)
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
    
    func addFriendRequestListener() {
        self.friendRequestToListener = friendRequestCollection.whereField("to", isEqualTo: CurrentUser.uid)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.friendRequests = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: FriendRequest.self)
                    } ?? []
                    self.filterUsers()
                }
            }
        self.myFriendRequestListener = friendRequestCollection.whereField("from", isEqualTo: CurrentUser.uid)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.myFriendRequests = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: FriendRequest.self)
                    } ?? []
                }
            }
    }
    
    func removeFriendRequestListener() {
        self.friendRequestToListener?.remove()
        self.myFriendRequestListener?.remove()
    }
}
