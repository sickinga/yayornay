//
//  FriendReques.swift
//  yayornay
//
//  Created by Thomas Sickinger on 30.01.23.
//

import Foundation

struct FriendRequest: Codable, Identifiable {
    var id: String { from + to }
    let from: String
    let fromName: String
    let to: String
    let toName: String
    
    init(from: String, fromName: String, to: String, toName: String) {
        self.from = from
        self.fromName = fromName
        self.to = to
        self.toName = toName
    }
    
    init(from: NamedUser, to: NamedUser) {
        self.from = from.id
        self.fromName = from.name
        self.to = to.id
        self.toName = to.name
    }
}
