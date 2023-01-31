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
    @StateObject var questionRepository: QuestionRepository = QuestionRepository()
    @State var questionText: String = ""
    @State var selectedQuestion: Question?
    @State var showAnswerView = false
    
    var body: some View {
        VStack {
            Text("\(authModel.user?.email ?? "")")
            Text("\(authModel.user?.displayName ?? "")")
            
            List {
                ForEach(questionRepository.questions) { question in
                    Button(action: {
                        self.selectedQuestion = question
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
            }
            .onAppear{
                questionRepository.addQuestionsListener(userId: authModel.user!.uid)
            }
            .onDisappear{questionRepository.removeQuestionsListener()}
            .sheet(
                isPresented: $showAnswerView,
                content: {
                    AnswerView(
                        isPresented: $showAnswerView,
                        user: authModel.user!,
                        question: selectedQuestion
                    )
                })
            
            TextField("Ask something", text: $questionText)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                .frame(width: 280, height: 45, alignment: .center)
            Button("Send!") {
                let question = Question(id: UUID(), created: Date.now, text: questionText, createdBy: authModel.user!.uid, answers: [], sentTo: [])
                questionRepository.add(question)
                questionText = ""
            }
        }.toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(
                    action: {
                        authModel.signOut()
                    },
                    label: {
                        Text("Sign Out")
                            .bold()
                    }
                )
            }
            ToolbarItemGroup(placement: .primaryAction) {
                NavigationLink(destination: FriendsView().environmentObject(authModel)) {
                    Label("", systemImage: "person.circle.fill")
                }
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
    @StateObject var questionRepository: QuestionRepository = QuestionRepository()
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
