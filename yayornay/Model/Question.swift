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
    var sentTo: [String]
    
    init(id: UUID, created: Date, text: String, createdBy: String, sentTo: [String]?) {
        self.id = id
        self.created = created
        self.text = text
        self.createdBy = createdBy
        self.sentTo = sentTo ?? []
    }
    
    init(question: Question, sentTo: [String]) {
        self.id = question.id
        self.created = question.created
        self.text = question.text
        self.createdBy = question.createdBy
        self.sentTo = sentTo
    }
}
