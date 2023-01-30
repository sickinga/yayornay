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
    @Published var questions: [Question] = []
    private let collection = Firestore.firestore().collection("question")
    private var listener: ListenerRegistration?
    
    func addQuestionsListener(userId: String) {
        self.listener = collection.whereField("createdBy", isEqualTo: userId)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.questions = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: Question.self)
                    } ?? []
                }
            }
    }
    
    func removeQuestionsListener() {
        self.listener?.remove()
    }
    
    func add(_ question: Question) {
        do {
            _ = try collection.document(question.id.uuidString).setData(from: question)
        } catch {
            fatalError("Unable to add question: \(error.localizedDescription).")
        }
    }
}
