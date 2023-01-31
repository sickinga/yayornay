//
//  Question.swift
//  yayornay
//
//  Created by Thomas Sickinger on 30.01.23.
//

import Foundation

struct Question: Identifiable, Codable {
    let id: UUID
    let created: Date
    var text: String
    var createdBy: String
    var sentTo: [String]
    var answers: [Answer]
    
    init(id: UUID, created: Date, text: String, createdBy: String, answers: [Answer]?, sentTo: [String]?) {
        self.id = id
        self.created = created
        self.text = text
        self.createdBy = createdBy
        self.answers = answers ?? []
        self.sentTo = sentTo ?? []
    }
    
    init(question: Question, sentTo: [String]) {
        self.id = question.id
        self.created = question.created
        self.text = question.text
        self.createdBy = question.createdBy
        self.answers = question.answers
        self.sentTo = sentTo
    }
}

struct Answer: Codable {
    let id: String
    var name: String
    var answer: Bool
}
