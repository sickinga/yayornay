//
//  QuestionRepository.swift
//  yayornay
//
//  Created by Thomas Sickinger on 30.01.23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class QuestionRepository: ObservableObject {
    private var userQuestions: [Question] = []
    private var askedQuestions: [Question] = []
    var questions: [Question] {
        [userQuestions + askedQuestions].flatMap { $0 }
    }
    var newQuestions: [Question] {
        askedQuestions.filter { userId != nil && $0.answers.contains { $0.id == userId } }
    }
    private let collection = Firestore.firestore().collection("question")
    private var userQuestionListener: ListenerRegistration?
    private var askedQuestionListener: ListenerRegistration?
    private var userId: String?
    
    func addQuestionsListener(userId: String) {
        self.userQuestionListener = collection.whereField("createdBy", isEqualTo: userId)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.userQuestions = querySnapshot?.documents.compactMap { document in
                        return try? document.data(as: Question.self)
                    } ?? []
                }
            }
        self.askedQuestionListener = collection.whereField("sentTo", arrayContains: userId)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.askedQuestions = querySnapshot?.documents.compactMap { document in
                        return try? document.data(as: Question.self)
                    } ?? []
                }
            }
    }
    
    func removeQuestionsListener() {
        self.userQuestionListener?.remove()
        self.askedQuestionListener?.remove()
    }
    
    func add(_ question: Question) {
        Firestore.firestore().collection("user/\(question.createdBy)/friends").getDocuments(completion: {querySnapshot, error in
            guard let documents = querySnapshot?.documents, error == nil else {
                return
            }
            let sentTo = documents.compactMap { queryDocumentSnapshot in
                try? queryDocumentSnapshot.data(as: NamedUser.self).id
            }
            do {
                _ = try self.collection.document(question.id.uuidString).setData(from: Question(question: question, sentTo: sentTo))
            } catch {
                fatalError("Unable to add question: \(error.localizedDescription).")
            }
        })
    }
    
    func answerQuestion(question: Question, answer: Answer) {
        do {
            _ = try self.collection.document(String(question.id.uuidString))
                .updateData(["answers": FieldValue.arrayUnion([Firestore.Encoder().encode(answer)])])
        } catch {
            fatalError("Unable to add question: \(error.localizedDescription).")
        }
    }
}
