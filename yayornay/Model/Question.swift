//
//  Question.swift
//  yayornay
//
//  Created by Thomas Sickinger on 30.01.23.
//

import Foundation

struct Question: Identifiable, Encodable, Decodable {
    let id: UUID
    let created: Date
    var text: String
    var createdBy: String
    
    init(id: UUID, text: String, createdBy: String, created: Date) {
        self.id = id
        self.text = text
        self.createdBy = createdBy
        self.created = created
    }
}
