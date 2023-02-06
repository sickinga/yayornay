//
//  MainViewModel.swift
//  yayornay
//
//  Created by Thomas Sickinger on 31.01.23.
//

import Foundation

class MainViewModel: ObservableObject {
    private var questionRepository: QuestionRepository = QuestionRepository()
    private var myQuestions: [Question] = []
    private var friendsQuestions: [Question] = []
    @Published var selectedQuestion: Question?
    @Published var questionText: String = ""
    @Published var showAnswerView = false
    @Published var questions: [Question] = []
    
    func initiate() {
        questionRepository.addQuestionsListener(
            myQuestionCompletion: { myQuestions in
                self.myQuestions = myQuestions
                self.sortQuestions()
            }, friendsQuestionCompletion: { friendsQuestions in
                self.friendsQuestions = friendsQuestions
                self.sortQuestions()
        })
    }
    
    func terminate() {
        questionRepository.removeQuestionsListener()
    }
    
    func refresh() {
        terminate()
        initiate()
    }
    
    private func sortQuestions() {
        self.questions = [self.myQuestions + self.friendsQuestions].flatMap { $0 }.sorted {
            $0.created > $1.created
        }
    }
    
    func sendQuestion() {
        let question = Question(
            id: UUID(),
            created: Date.now,
            text: questionText,
            createdBy: CurrentUser.uid,
            createdByName: CurrentUser.name,
            answers: [:],
            sentTo: []
        )
        questionRepository.add(question)
        questionText = ""
    }
    
    func isNewQuestion(_ question: Question) -> Bool {
        return question.createdBy != CurrentUser.uid && !question.answers.contains(where: { $0.value.id == CurrentUser.uid })
    }
    
    func selectQuestion(_ question: Question) {
        selectedQuestion = question
        showAnswerView = true
    }
    
    func answerQuestion(answer: Bool) {
        questionRepository
            .answerQuestion(
                question: selectedQuestion!,
                answer: Answer(id: CurrentUser.uid, name: CurrentUser.name, answer: answer))
        showAnswerView.toggle()
    }
}
