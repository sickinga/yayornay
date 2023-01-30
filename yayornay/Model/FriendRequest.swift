//
//  FriendReques.swift
//  yayornay
//
//  Created by Thomas Sickinger on 30.01.23.
//

import Foundation

struct FriendRequest: Encodable {
    let from: NamedUser
    var to: NamedUser
}
