//
//  QuestionRepository.swift
//  yayornay
//
//  Created by Thomas Sickinger on 30.01.23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class QuestionRepository: ObservableObject {
    private let collection = Firestore.firestore().collection("question")
    private var myQuestionListener: ListenerRegistration?
    private var friendsQuestionListener: ListenerRegistration?
    private var userId: String?
    
    func addQuestionsListener(
        myQuestionCompletion: @escaping ([Question]) -> Void,
        friendsQuestionCompletion: @escaping ([Question]) -> Void
    ) {
        self.myQuestionListener = collection.whereField("createdBy", isEqualTo: CurrentUser.uid)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    let myQuestions = querySnapshot?.documents.compactMap { document in
                        return try? document.data(as: Question.self)
                    } ?? []
                    myQuestionCompletion(myQuestions)
                }
            }
        self.friendsQuestionListener = collection.whereField("sentTo", arrayContains: CurrentUser.uid)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    let friendsQuestions = querySnapshot?.documents.compactMap { document in
                        return try? document.data(as: Question.self)
                    } ?? []
                    friendsQuestionCompletion(friendsQuestions)
                }
            }
    }
    
    func removeQuestionsListener() {
        self.myQuestionListener?.remove()
        self.friendsQuestionListener?.remove()
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
        var question: Question = question
        question.answers[CurrentUser.uid] = answer
        do {
            _ = try self.collection.document(String(question.id.uuidString))
                .setData(from: question, merge: true)
        } catch {
            fatalError("Unable to add question: \(error.localizedDescription).")
        }
    }
}
