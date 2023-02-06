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
            if vm.showFriendList {
                Section("My Friends (\(vm.friends.count))") {
                    ForEach(vm.friends) { friend in
                        HStack {
                            Text(friend.name)
                            Spacer()
                            Button(action: { vm.removeFriend(friend) }, label: {
                                Image(systemName: "xmark")
                            })
                            .tint(.gray)
                            .font(.footnote)
                        }
                    }
                }
            }
            if vm.showNoFriendsHint {
                HStack {
                    Spacer()
                    Text("Find your friends first...")
                    Spacer()
                }
            }
            if vm.showFriendRequestList {
                Section("Friend Requests") {
                    ForEach(vm.friendRequests) { request in
                        HStack {
                            Text(request.fromName)
                            Spacer()
                            Button("ADD") {
                                vm.answerFriendRequest(friendRequest: request, accept: true)
                            }
                            Button("DENY") {
                                vm.answerFriendRequest(friendRequest: request, accept: false)
                            }
                        }.swipeActions {
                            Button {
                                vm.answerFriendRequest(friendRequest: request, accept: true)
                            } label: {
                                Label("ADD", systemImage: "checkmark.circle.fill")
                            }.tint(Color.green)
                            Button {
                                vm.answerFriendRequest(friendRequest: request, accept: false)
                            } label: {
                                Label("DENY", systemImage: "minus.circle.fill")
                            }
                            .tint(Color.red)
                        }
                    }
                }
            }
            if vm.showNoFriendRequestsHint {
                HStack {
                    Spacer()
                    Text("No pending requests")
                    Spacer()
                }
            }
            if vm.showMoreResultsList {
                Section("More Results") {
                    ForEach(vm.filteredUsers) { user in
                        HStack {
                            Text(user.name)
                            Spacer()
                            if vm.myFriendRequests.contains { $0.to == user.id } {
                                Text("ADDED")
                            } else {
                                Button("ADD") {
                                    vm.sendFriendRequest(fromUser: authModel.user!, toNamedUser: user)
                                }.swipeActions {
                                    Button {
                                        vm.sendFriendRequest(fromUser: authModel.user!, toNamedUser: user)
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
                    vm.searchFriends(newValue)
                }
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
