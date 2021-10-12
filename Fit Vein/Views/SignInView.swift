//
//  SignInView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 12/10/2021.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var sessionStore: SessionStore
    
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                HStack {
                    Text("E-mail")
                    Spacer()
                }
                
                TextField("", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
            }
            .padding()
            
            VStack {
                HStack {
                    Text("Password")
                    Spacer()
                }
                
                TextField("", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                if !email.isEmpty && !password.isEmpty {
                    sessionStore.signIn(email: email, password: password)
                }
            }, label: {
                Text("Sign In")
            })
            
            NavigationLink("Create Account", destination: SignUpView().environmentObject(sessionStore))
                .padding()
        }
        .navigationTitle("Sign In")
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                SignInView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
