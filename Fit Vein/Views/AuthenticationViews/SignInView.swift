//
//  SignInView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 12/10/2021.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @StateObject private var signInViewModel = SignInViewModel()
    @Environment(\.colorScheme) var colorScheme
    
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
                        Image(uiImage: UIImage(named: colorScheme == .dark ? "FitVeinIconDark" : "FitVeinIconLight")!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
                            .padding(.leading, screenWidth * 0.13)
                        
                        Spacer()
                        
                        Text("Sign In Form")
                            .font(.system(size: screenHeight * 0.04, weight: .bold))
                        
                        Spacer()
                    }
                    
                    VStack {
                        HStack {
                            Text("E-mail")
                            Spacer()
                        }
                        
                        VStack {
                            TextField("E-mail", text: $email)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                            Divider()
                                .background(appPrimaryColor)
                        }
                        
                    }
                    .padding()
                    
                    VStack {
                        HStack {
                            Text("Password")
                            Spacer()
                        }
                        
                        VStack {
                            SecureField("Password", text: $password)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                            Divider()
                                .background(appPrimaryColor)
                        }
                        
                        HStack {
                            Text("Forgot Password?")
                                .font(.system(size: screenHeight * 0.018))
                                .foregroundColor(appPrimaryColor)
                                .onTapGesture {
                                    showForgotPasswordSheet = true
                                }
                            Spacer()
                        }
                        
                    }
                    .padding()
                }
                .background(RoundedRectangle(cornerRadius: 25)
                                .foregroundColor(.black.opacity(0.7))
                                .frame(width: screenWidth * 0.98, height: screenHeight * 0.55))
                

                Button(action: {
                    if checkDataIsCorrect() {
                        signInViewModel.signIn(email: email, password: password)
                    }
                }, label: {
                    Text("Sign In")
                })
                .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor(appPrimaryColor))
                .padding()
                .padding(.top, screenHeight * 0.05)
                
                Spacer()
                
                HStack {
                    Text("Don't have an account?")
                    NavigationLink("Create One", destination: SignUpView().environmentObject(sessionStore).ignoresSafeArea(.keyboard))
                        .foregroundColor(appPrimaryColor)
                }
                .padding(.bottom, screenHeight * 0.05)
            }
            .onAppear {
                self.signInViewModel.setup(sessionStore: sessionStore)
            }
            .foregroundColor(.white)
            .background(Image("SignUpBackgroundImage")
                            .resizable()
                            .ignoresSafeArea()
                            .scaledToFill())
            .sheet(isPresented: $showForgotPasswordSheet, content: {
                NavigationView {
                    ScrollView(.vertical) {
                        Form {
                            Section(header: Text("Forgot Password"), footer: sendRecoveryEmailButtonPressed ? (recoveryEmailSent ? Text("Recovery e-mail has been sent! Please check your inbox.").foregroundColor(appPrimaryColor) : Text("Please provide correct e-mail address.").foregroundColor(.red)) : Text("Please provide your e-mail address so that we could send you recovery e-mail with instructions how to reset the password.")) {
                                TextField("E-mail", text: $forgotPasswordEmail)
                            }
                        }
                        .frame(width: screenWidth, height: screenHeight * 0.80)
                        
                        HStack {
                            Button(action: {
                                withAnimation {
                                    sendRecoveryEmailButtonPressed = true
                                    if checkEmail(email: forgotPasswordEmail) {
                                        signInViewModel.sendRecoveryEmail(email: forgotPasswordEmail)
                                        recoveryEmailSent = true
                                    }
                                }
                            }, label: {
                                Text("Send Recovery E-mail")
                                    .foregroundColor(.white)
                            })
                            .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor(appPrimaryColor))
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
    
    private func checkEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
    
    private func checkFieldsNotEmpty() -> Bool {
        if email.isEmpty || password.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    private func checkDataIsCorrect() -> Bool {
        return checkEmail(email: email) && checkFieldsNotEmpty()
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
                    .environmentObject(SessionStore(forPreviews: true))
            }
        }
    }
}
