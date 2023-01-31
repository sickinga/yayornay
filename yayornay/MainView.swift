//
//  MainView.swift
//  yayornay
//
//  Created by Thomas Sickinger on 29.01.23.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @EnvironmentObject private var authModel: AuthViewModel
    @ObservedObject var questionRepository: QuestionRepository = QuestionRepository()
    @State var questionText: String = ""
    @ObservedObject var vm = MainViewModel()
    @State var showAnswerView = false
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Yay or Nay")
                    .font(.largeTitle)
                
                TextField("Ask something", text: $questionText)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 280, height: 45, alignment: .center)
                Button("Send!") {
                    let question = Question(id: UUID(), created: Date.now, text: questionText, createdBy: authModel.user!.uid, answers: [], sentTo: [])
                    questionRepository.add(question)
                    questionText = ""
                }
                
                if !questionRepository.questions.isEmpty {
                    Text("History")
                        .font(.title2)
                        .padding()
                    
                    List {
                        ForEach(questionRepository.questions) { question in
                            Button(action: {
                                vm.selectedQuestion = question
                                self.showAnswerView = true
                            }, label: {
                                Label {
                                    Text(question.text)
                                    Spacer()
                                } icon: {
                                    if isNewQuestion(question) {
                                        Circle()
                                            .fill(.blue)
                                            .frame(width: 12, height: 12)
                                    }
                                }
                            })
                        }
                    }.sheet(
                        isPresented: $showAnswerView,
                        content: {
                            AnswerView(
                                questionRepository: questionRepository,
                                isPresented: $showAnswerView,
                                user: authModel.user!,
                                question: vm.selectedQuestion
                            )
                            .presentationDetents([.medium, .large])
                        })
                    
                }
            }.toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    NavigationLink(destination: AccountView().environmentObject(authModel)) {
                        Label("", systemImage: "person.fill")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    NavigationLink(destination: FriendsView().environmentObject(authModel)) {
                        Label("", systemImage: "person.2.fill")
                    }
                }
            }.onAppear {
                questionRepository.addQuestionsListener(userId: authModel.user!.uid)
            }.onDisappear {
                questionRepository.removeQuestionsListener()
            }.refreshable {
                questionRepository.removeQuestionsListener()
                questionRepository.addQuestionsListener(userId: authModel.user!.uid)
            }
        }
    }
    
    func isNewQuestion(_ question: Question) -> Bool {
        return question.createdBy != authModel.user?.uid && !question.answers.contains(where: { $0.id == authModel.user?.uid })
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AuthViewModel())
    }
}

struct AnswerView: View {
    var questionRepository: QuestionRepository
    @Binding var isPresented: Bool
    let user: User
    let question: Question?
    
    var body: some View {
        VStack {
            Text(question?.text ?? "")
                .font(.title)
                .padding()
            HStack{
                Button(action: {
                    answerQuestion(true)
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .foregroundColor(.green)
                        .frame(width: 64, height: 64)
                }
                Button(action: {
                    answerQuestion(false)
                }) {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .foregroundColor(.red)
                        .frame(width: 64, height: 64)
                }
            }
        }
    }
    
    func answerQuestion(_ answer: Bool) {
        questionRepository
            .answerQuestion(
                question: question!,
                answer: Answer(id: user.uid, name: user.displayName ?? "", answer: true))
        isPresented.toggle()
    }
}
