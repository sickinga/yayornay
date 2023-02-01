//
//  Question.swift
//  yayornay
//
//  Created by Thomas Sickinger on 30.01.23.
//

import Foundation

struct Question: Identifiable, Codable {
    let id: UUID
    var text: String
    let created: Date
    var createdBy: String
    var createdByName: String
    var sentTo: [String]
    var answers: [String: Answer]
    var yayPercentage: Int {
        answers.isEmpty ? 0 :
            (100 * answers.map { $0.value.answer }.filter { $0 }.count) / answers.count
    }
    var nayPercentage: Int {
        answers.isEmpty ? 0 :
            (100 * answers.map { $0.value.answer }.filter { !$0 }.count) / answers.count
    }
    
    init(id: UUID, created: Date, text: String, createdBy: String, createdByName: String, answers: [String: Answer]?, sentTo: [String]?) {
        self.id = id
        self.text = text
        self.created = created
        self.createdBy = createdBy
        self.createdByName = createdByName
        self.answers = answers ?? [:]
        self.sentTo = sentTo ?? []
    }
    
    init(question: Question, sentTo: [String]) {
        self.id = question.id
        self.text = question.text
        self.created = question.created
        self.createdBy = question.createdBy
        self.createdByName = question.createdByName
        self.answers = question.answers
        self.sentTo = sentTo
    }
}

struct Answer: Codable {
    let id: String
    var name: String
    var answer: Bool
}
