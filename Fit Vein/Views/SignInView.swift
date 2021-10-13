//
//  SignInView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 12/10/2021.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @ObservedObject private var signInViewModel = SignInViewModel()
    
    @State var email: String = ""
    @State var password: String = ""
    
    @State private var forgotPasswordEmail = ""
    @State private var wrongCredentials = false
    @State private var showForgotPasswordSheet = false
    @State private var sendRecoveryEmailButtonPressed = false
    @State private var recoveryEmailSent = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                Spacer()
                
                VStack {
                    HStack {
                        Text("E-mail")
                        Spacer()
                    }
                    
                    TextField("E-Mail", text: $email)
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
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    HStack {
                        Text("Forgot Password?")
                            .font(.system(size: screenHeight * 0.018))
                            .foregroundColor(.green)
                            .onTapGesture {
                                showForgotPasswordSheet = true
                            }
                        Spacer()
                    }
                    
                }
                .padding()

                Button(action: {
                    if !email.isEmpty && !password.isEmpty {
                        signInViewModel.signIn(email: email, password: password)
                    }
                }, label: {
                    Text("Sign In")
                })
                .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor(.green))
                .padding()
                .padding(.top, screenHeight * 0.05)
                
                Spacer()
                
                HStack {
                    Text("Don't have an account?")
                    NavigationLink("Create One", destination: SignUpView().environmentObject(sessionStore).ignoresSafeArea(.keyboard))
                        .foregroundColor(.green)
                }
                
                    
            }
            .onAppear {
                self.signInViewModel.setup(sessionStore: sessionStore)
                print("TUTAJ2 \(signInViewModel.sessionStore == nil)")
            }
            .navigationTitle("Sign In")
            .foregroundColor(.white)
            .background(Image("SignUpBackgroundImage")
                            .resizable()
                            .ignoresSafeArea()
                            .scaledToFill())
            .sheet(isPresented: $showForgotPasswordSheet, content: {
                NavigationView {
                    ScrollView(.vertical) {
                        Form {
                            Section(header: Text("Forgot Password"), footer: sendRecoveryEmailButtonPressed ? (recoveryEmailSent ? Text("Recovery e-mail has been sent! Please check your inbox.").foregroundColor(.green) : Text("Please provide correct e-mail address.").foregroundColor(.red)) : Text("Please provide your e-mail address so that we could send you recovery e-mail with instructions how to reset the password.")) {
                                TextField("E-mail", text: $forgotPasswordEmail)
                            }
                        }
                        .frame(width: screenWidth, height: screenHeight * 0.80)
                        
                        HStack {
                            Button(action: {
                                withAnimation {
                                    sendRecoveryEmailButtonPressed = true
                                    if checkEmail() {
//                                        sessionStore.sendRecoveryEmail(forgotPasswordEmail) {
//                                            print("Successfully sent recovery e-mail.")
//                                        }
                                        recoveryEmailSent = true
                                    }
                                }
                            }, label: {
                                Text("Send Recovery E-mail")
                                    .foregroundColor(.white)
                            })
                            .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor(.green))
                            .padding()
                        }
                        .frame(width: screenWidth * 0.6, height: screenHeight * 0.07)
                    }
                    .navigationBarTitle("Forgot Password Form", displayMode: .inline)
                }
                .ignoresSafeArea(.keyboard)
            })
        }
    }
    
    private func checkEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: forgotPasswordEmail)
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
                    .environmentObject(SessionStore())
            }
        }
    }
}
