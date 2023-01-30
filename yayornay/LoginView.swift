//
//  LoginView.swift
//  yayornay
//
//  Created by Thomas Sickinger on 29.01.23.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject private var authModel: AuthViewModel
    @State private var isLogin = false
    @State var email = ""
    @State var password = ""
    @State var name = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Picker("", selection: $isLogin) {
                    Text("Log In")
                        .tag(true)
                    Text("Create Account")
                        .tag(false)
                }.pickerStyle(SegmentedPickerStyle())
                .padding()
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 280, height: 45, alignment: .center)
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 280, height: 45, alignment: .center)
                if !isLogin {
                    TextField("Name", text: $name)
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 280, height: 45, alignment: .center)
                }
                Button(action: {
                    if isLogin {
                        loginUser()
                    } else {
                        createUser()
                    }
                }, label: {
                    Text(isLogin ? "Log In" : "Create Account")
                    .foregroundColor(.white)
                }).frame(width: 280, height: 45, alignment: .center)
                    .background(Color.blue)
                    .cornerRadius(8)
                Spacer()
            }.navigationTitle(isLogin ? "Welcome Back" : "Welcome")
        }
    }
    
    private func loginUser() {
        authModel.signIn(emailAddress: email, password: password)
    }
    
    private func createUser() {
        authModel.signUp(emailAddress: email, password: password, name: name)
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
