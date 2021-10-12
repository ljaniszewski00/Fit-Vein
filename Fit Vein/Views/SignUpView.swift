//
//  SignUpView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 12/10/2021.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var sessionStore: SessionStore
    
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            TextField("E-mail", text: $email)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .padding()
            SecureField("Password", text: $password)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .padding()
            
            Spacer()
            
            Button(action: {
                if !email.isEmpty && !password.isEmpty {
                    sessionStore.signIn(email: email, password: password)
                }
            }, label: {
                Text("Sign Up")
            })
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
