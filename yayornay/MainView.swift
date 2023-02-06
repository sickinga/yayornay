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
    @ObservedObject var vm = MainViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                Image("yay-or-nay")
                    .resizable()
                    .frame(width: 280, height: 280)
                
                TextField("Ask something", text: $vm.questionText, axis: .vertical)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 25)
                    .padding(.vertical)
                    .lineLimit(3, reservesSpace: true)
                Button(action: {
                    vm.sendQuestion()
                }, label: {
                    Label("Send!", systemImage: "paperplane.fill")
                }).buttonStyle(.borderedProminent)
                    .tint(.yay)
                    .disabled(vm.questionText.isEmpty)
                
                if !vm.questions.isEmpty {
                    Text("History")
                        .font(.title2)
                        .padding()
                    
                    ForEach(vm.questions) { question in
                        VStack {
                            Button(action: {
                                vm.selectQuestion(question)
                            }, label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(question.text)
                                            .foregroundColor(Color(UIColor.label))
                                        Text("from \(question.createdByName)")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        if vm.isNewQuestion(question) {
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
                                .padding(.horizontal, 25)
                            Divider()
                        }
                    }
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
            }.sheet(
                isPresented: $vm.showAnswerView,
                content: {
                    AnswerView(
                        answerQuestion: vm.answerQuestion,
                        question: vm.selectedQuestion
                    )
                    .presentationDetents([.medium, .large])
            }).onAppear {
                vm.initiate()
            }.onDisappear {
                vm.terminate()
            }.refreshable {
                vm.refresh()
            }.scrollDismissesKeyboard(.immediately)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AuthViewModel())
    }
}

struct AnswerView: View {
    let answerQuestion: (Bool) -> Void
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
}

struct Evaluation: Identifiable {
    let id = UUID()
    let type: String
    let value: Int
    let color: Color
}
