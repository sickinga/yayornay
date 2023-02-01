//
//  MainView.swift
//  yayornay
//
//  Created by Thomas Sickinger on 29.01.23.
//

import SwiftUI
import FirebaseAuth
import Charts

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
                
                TextField("Ask something", text: $questionText, axis: .vertical)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 25)
                    .padding(.vertical)
                    .lineLimit(3, reservesSpace: true)
                Button(action: {
                    let question = Question(id: UUID(), created: Date.now, text: questionText, createdBy: CurrentUser.uid, createdByName: CurrentUser.name, answers: [:], sentTo: [])
                    questionRepository.add(question)
                    questionText = ""
                }, label: {
                    Label("Send!", systemImage: "paperplane.fill")
                }).buttonStyle(.borderedProminent)
                    .tint(.yay)
                    .disabled(questionText.isEmpty)
                
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
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(question.text)
                                        Text("from \(question.createdByName)")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        if isNewQuestion(question) {
                                            Circle()
                                                .fill(.blue)
                                                .frame(width: 12, height: 12)
                                        } else {
                                            if(question.answers.isEmpty) {
                                                Text("No answers")
                                            } else {
                                                Text("\(question.yayPercentage) %")
                                            }
                                        }
                                        Text(question.created.timeAgoDisplay())
                                            .font(.footnote)
                                    }.foregroundColor(.gray)
                                }
                            }).padding(.vertical, 3)
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
                    .listStyle(.inset)
                }
            }.toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    NavigationLink(destination: FriendsView().environmentObject(authModel)) {
                        Label("", systemImage: "person.2.fill")
                            .tint(Color(UIColor.label))
                    }
                }
                ToolbarItemGroup(placement: .primaryAction) {
                    NavigationLink(destination: AccountView().environmentObject(authModel)) {
                        Label("", systemImage: "person.circle")
                            .tint(Color(UIColor.label))
                    }
                }
            }.onAppear {
                questionRepository.addQuestionsListener()
            }.onDisappear {
                questionRepository.removeQuestionsListener()
            }.refreshable {
                questionRepository.removeQuestionsListener()
                questionRepository.addQuestionsListener()
            }
        }
    }
    
    func isNewQuestion(_ question: Question) -> Bool {
        return question.createdBy != CurrentUser.uid && !question.answers.contains(where: { $0.value.id == CurrentUser.uid })
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
    var evaluationData: [Evaluation] {[
        Evaluation(type: "Yay", value: question?.yayPercentage ?? 0, color: .yay),
        Evaluation(type: "Nay", value: question?.nayPercentage ?? 0, color: .nay)
    ]}
    
    var body: some View {
        VStack {
            Text(question?.text ?? "")
                .font(.title)
            Text("from \(question?.createdByName ?? "404 Name not found")")
                .foregroundColor(.gray)
                .padding(.bottom)
            if question?.createdBy == CurrentUser.uid {
                Chart(evaluationData) {
                    BarMark(
                        x: .value("Type", $0.type),
                        y: .value("Percentage", $0.value)
                    ).foregroundStyle($0.color)
                }.frame(width: 280, height: 280)
                    .chartYScale(domain: 0...100)
            } else {
                HStack{
                    Button(action: {
                        answerQuestion(true)
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .foregroundColor(.yay)
                            .frame(width: 96, height: 96)
                            .padding()
                    }
                    Button(action: {
                        answerQuestion(false)
                    }) {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .foregroundColor(.nay)
                            .frame(width: 96, height: 96)
                            .padding()
                    }
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

struct Evaluation: Identifiable {
    let id = UUID()
    let type: String
    let value: Int
    let color: Color
}
