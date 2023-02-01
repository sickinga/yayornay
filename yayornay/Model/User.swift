//
//  User.swift
//  yayornay
//
//  Created by Thomas Sickinger on 29.01.23.
//

import Foundation
import FirebaseAuth

struct NamedUser: Identifiable, Codable {
    let id: String
    var name: String
    var keywordsForLookup: [String] {
        self.name.generateStringSequence()
    }
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    init(user: User) {
        self.id = user.uid
        self.name = user.displayName ?? ""
    }
}

extension String {
    func generateStringSequence() -> [String] {
        var sequences: [String] = []
        for i in 1...self.count {
            sequences.append(String(self.prefix(i).lowercased()))
        }
        return sequences
    }
}

struct CurrentUser {
    static var uid: String {
        UserDefaults.standard.string(forKey: "uid")!
    }
    
    static var name: String {
        UserDefaults.standard.string(forKey: "name")!
    }
}
