//
//  FriendsView.swift
//  yayornay
//
//  Created by Thomas Sickinger on 30.01.23.
//

import SwiftUI

struct FriendsView: View {
    @EnvironmentObject private var authModel: AuthViewModel
    @ObservedObject var vm = FriendsViewModel()
    
    var body: some View {
        List {
            if !vm.friends.isEmpty && (!vm.searchString.isEmpty || vm.isFriendView) {
                Section("My Friends (\(vm.friends.count))") {
                    ForEach(vm.friends) { friend in
                        HStack {
                            Text(friend.name)
                            Spacer()
                            Button(action: { vm.userRepository.removeFriend(friend) }, label: {
                                Image(systemName: "xmark")
                            })
                            .tint(.gray)
                            .font(.footnote)
                        }
                    }
                }
            }
            if vm.friends.isEmpty && vm.searchString.isEmpty && vm.isFriendView {
                HStack {
                    Spacer()
                    Text("Find your friends first...")
                    Spacer()
                }
            }
            if !vm.friendRequests.isEmpty && (!vm.searchString.isEmpty || !vm.isFriendView) {
                Section("Friend Requests") {
                    ForEach(vm.friendRequests) { request in
                        HStack {
                            Text(request.fromName)
                            Spacer()
                            Button("ADD") {
                                vm.userRepository.answerFriendRequest(friendRequest: request, accept: true)
                            }
                            Button("DENY") {
                                vm.userRepository.answerFriendRequest(friendRequest: request, accept: false)
                            }
                        }.swipeActions {
                            Button {
                                vm.userRepository.answerFriendRequest(friendRequest: request, accept: true)
                            } label: {
                                Label("ADD", systemImage: "checkmark.circle.fill")
                            }.tint(Color.green)
                            Button {
                                vm.userRepository.answerFriendRequest(friendRequest: request, accept: false)
                            } label: {
                                Label("DENY", systemImage: "minus.circle.fill")
                            }
                            .tint(Color.red)
                        }
                    }
                }
            }
            if vm.userRepository.friendRequests.isEmpty && vm.searchString.isEmpty && !vm.isFriendView {
                HStack {
                    Spacer()
                    Text("No pending requests")
                    Spacer()
                }
            }
            if !vm.searchString.isEmpty && !vm.userRepository.filteredUsers.isEmpty {
                Section("More Results") {
                    ForEach(vm.userRepository.filteredUsers) { user in
                        HStack {
                            Text(user.name)
                            Spacer()
                            if vm.userRepository.myFriendRequests.contains { $0.to == user.id } {
                                Text("ADDED")
                            } else {
                                Button("ADD") {
                                    vm.userRepository.sendFriendRequest(FriendRequest(from: NamedUser(user: authModel.user!), to: user))
                                }.swipeActions {
                                    Button {
                                        vm.userRepository.sendFriendRequest(FriendRequest(from: NamedUser(user: authModel.user!), to: user))
                                    } label: {
                                        Label("ADD", systemImage: "plus.circle.fill")
                                    }.tint(Color.yay)
                                }
                            }
                        }
                    }
                }
            }
        }.searchable(text: $vm.searchString, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: vm.searchString, perform: { newValue in
                if vm.isFriendView {
                    if newValue.isEmpty {
                        vm.filteredFriends = []
                    } else {
                        vm.filteredFriends = vm.userRepository.friends.filter { $0.name.lowercased().contains(vm.searchString.lowercased())
                        }
                    }
                }
                vm.userRepository.search(vm.searchString)
            }).onAppear {
                vm.initiate()
            }.onDisappear {
                vm.terminate()
            }.safeAreaInset(edge: .bottom) {
                Picker("", selection: $vm.isFriendView) {
                    Text("Friends")
                        .tag(true)
                    Text("Requests")
                        .tag(false)
                }.pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .onChange(of: vm.isFriendView, perform: { newValue in vm.searchString = ""})
            }.navigationBarTitle(vm.isFriendView ? "Friends" : "Friend Requests")
                .navigationBarTitleDisplayMode(.inline)
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
