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
    
    @State private var wrongCredentials = false
    @State private var showForgotPasswordSheet = false
    
    @FocusState private var isEmailTextFieldFocused: Bool
    @FocusState private var isPasswordTextFieldFocused: Bool

    
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
                                .focused($isEmailTextFieldFocused)
                                .onSubmit {
                                    isEmailTextFieldFocused = false
                                    isPasswordTextFieldFocused = true
                                }
                            Divider()
                                .background(Color.accentColor)
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
.focused($isPasswordTextFieldFocused)
.onSubmit {
    isPasswordTextFieldFocused = false
}
                            Divider()
                                .background(Color.accentColor)
                        }
                        
                        HStack {
                            Text("Forgot Password?")
                                .font(.system(size: screenHeight * 0.018))
                                .foregroundColor(.accentColor)
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
                    if email.isEmpty {
                        isEmailTextFieldFocused = true
                    } else if password.isEmpty {
                        isPasswordTextFieldFocused = true
                    } else {
                        isEmailTextFieldFocused = false
                        isPasswordTextFieldFocused = false
                        if checkDataIsCorrect() {
                            signInViewModel.signIn(email: email, password: password)
                        }
                    }
                }, label: {
                    Text("Sign In")
                })
                .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor(.accentColor))
                .padding()
                .padding(.top, screenHeight * 0.05)
                
                Spacer()
                
                HStack {
                    Text("Don't have an account?")
                    NavigationLink("Create One", destination: SignUpView().environmentObject(sessionStore).ignoresSafeArea(.keyboard))
                        .foregroundColor(.accentColor)
                }
                .padding(.bottom, screenHeight * 0.05)
            }
            .onAppear {
                self.signInViewModel.setup(sessionStore: sessionStore)
            }
            .offset(y: isEmailTextFieldFocused ? -screenHeight * 0.25 : (isPasswordTextFieldFocused ? -screenHeight * 0.25 : 0))
            .foregroundColor(.white)
            .background(Image("SignUpBackgroundImage")
                            .resizable()
                            .ignoresSafeArea()
                            .scaledToFill())
            .sheet(isPresented: $showForgotPasswordSheet, content: {
                forgotPasswordSheetView().environmentObject(signInViewModel).ignoresSafeArea(.keyboard)
            })
        }
    }
    
    struct forgotPasswordSheetView: View {
        @EnvironmentObject private var signInViewModel: SignInViewModel
        
        @State private var forgotPasswordEmail = ""
        @State private var sendRecoveryEmailButtonPressed = false
        @State private var recoveryEmailSent = false
        
        @FocusState private var isTextFieldFocused: Bool
        
        var body: some View {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let screenHeight = geometry.size.height
                
                NavigationView {
                    ScrollView(.vertical) {
                        Form {
                            Section(header: Text("Forgot Password"), footer: sendRecoveryEmailButtonPressed ? (recoveryEmailSent ? Text("Recovery e-mail has been sent! Please check your inbox.").foregroundColor(.accentColor) : Text("Please provide correct e-mail address.").foregroundColor(.red)) : Text("Please provide your e-mail address so that we could send you recovery e-mail with instructions how to reset the password.")) {
                                TextField("E-mail", text: $forgotPasswordEmail)
                                    .focused($isTextFieldFocused)
                            }
                        }
                        .frame(width: screenWidth, height: screenHeight * 0.80)
                        
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
                        .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor(.accentColor))
                        .padding()
                        .offset(y: isTextFieldFocused ? -screenHeight * 0.35 : -screenHeight * 0.1)
                    }
                    .navigationBarTitle("Forgot Password Form", displayMode: .inline)
                }
            }
        }
        
        private func checkEmail(email: String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
        }
    }
    
    private func checkEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
    
    private func checkDataIsCorrect() -> Bool {
        return checkEmail(email: email)
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
