//
//  User.swift
//  yayornay
//
//  Created by Thomas Sickinger on 29.01.23.
//

import Foundation

struct NamedUser: Identifiable, Codable {
    let id: String
    var name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
