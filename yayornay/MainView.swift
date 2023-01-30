//
//  MainView.swift
//  yayornay
//
//  Created by Thomas Sickinger on 29.01.23.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var authModel: AuthViewModel
    @StateObject var questionRepository: QuestionRepository = QuestionRepository()
    @State var questionText: String = ""
    
    var body: some View {
        VStack {
            Text("\(authModel.user?.email ?? "")")
            Text("\(authModel.user?.displayName ?? "")")
            
            List {
                ForEach(questionRepository.questions) { question in
                    Text(question.text)
                }
            }
            .onAppear{
                questionRepository.addQuestionsListener(userId: authModel.user!.uid)
            }
            .onDisappear{questionRepository.removeQuestionsListener()}
            
            TextField("Ask something", text: $questionText)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                .frame(width: 280, height: 45, alignment: .center)
            Button("Send!") {
                let question = Question(id: UUID(), text: questionText, createdBy: authModel.user!.uid, created: Date.now)
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
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AuthViewModel())
    }
}
