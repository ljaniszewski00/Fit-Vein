//
//  SignInView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 12/10/2021.
//

import SwiftUI

struct SignInView: View {
    @StateObject private var signInViewModel = SignInViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    @State var email: String = ""
    @State var password: String = ""
    
    @State private var wrongCredentials = false
    @State private var showForgotPasswordSheet = false
    
    @State private var isEmailTextFieldFocused: Bool = false
    @State private var isPasswordTextFieldFocused: Bool = false
    
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
                        
                        Text(String(localized: "SignInView_sign_in_form_label"))
                            .font(.system(size: screenHeight * 0.04, weight: .bold))
                        
                        Spacer()
                    }
                    
                    CustomTextField(textFieldProperty: String(localized: "SignInView_email_label"), textFieldImageName: "envelope", textFieldSignsLimit: 0, text: $email, isFocusedParentView: $isEmailTextFieldFocused)
                        .padding(.bottom, -screenHeight * 0.02)
                    
                    VStack {
                        CustomTextField(isSecureField: true, textFieldProperty: String(localized: "SignInView_password_label"), textFieldImageName: "lock", text: $password, isFocusedParentView: $isPasswordTextFieldFocused)
                        
                        HStack {
                            Text(String(localized: "SignInView_email_label"))
                                .font(.system(size: screenHeight * 0.018))
                                .foregroundColor(.accentColor)
                                .onTapGesture {
                                    showForgotPasswordSheet = true
                                }
                            Spacer()
                        }
                        .padding()
                        .offset(y: -screenHeight * 0.045)
                    }
                    
                    if wrongCredentials {
                        HStack {
                            LottieView(name: "wrongData", loopMode: .loop, contentMode: .scaleAspectFill)
                                .frame(width: screenWidth * 0.15, height: screenHeight * 0.05)
                                .padding(.leading)
                                .offset(y: -screenHeight * 0.013)
                            Text(String(localized: "SignInView_sign_in_wrong_data_label"))
                                .foregroundColor(.red)
                                .font(.system(size: screenWidth * 0.035, weight: .bold))
                            Spacer()
                        }
                        .padding(.horizontal)
                        .offset(y: -screenHeight * 0.05)
                    }
                }
                .background(RoundedRectangle(cornerRadius: 25)
                                .foregroundColor(.black.opacity(0.7))
                                .frame(width: screenWidth * 0.98, height: screenHeight * 0.55))
                

                Button(action: {
                    withAnimation {
                        isEmailTextFieldFocused = false
                        isPasswordTextFieldFocused = false
                        wrongCredentials = false
                        signInViewModel.signIn(email: email, password: password) { success in
                            self.wrongCredentials = !success
                        }
                    }
                }, label: {
                    Text("Sign In")
                })
                .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor(.accentColor))
                .padding()
                .padding(.top, screenHeight * 0.05)
                .disabled(email.isEmpty ? true : (password.isEmpty ? true : false))
                .offset(y: isEmailTextFieldFocused ? -screenHeight * 0.02 : (isPasswordTextFieldFocused ? -screenHeight * 0.02 : 0))
                
                Spacer()
                
                HStack {
                    Text(String(localized: "SignInView_no_account_label"))
                    NavigationLink(String(localized: "SignInView_create_account_button"), destination: SignUpView().ignoresSafeArea(.keyboard))
                        .foregroundColor(.accentColor)
                }
                .padding(.bottom, screenHeight * 0.05)
                .offset(y: isEmailTextFieldFocused ? -screenHeight * 0.1 : (isPasswordTextFieldFocused ? -screenHeight * 0.1 : 0))
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
        @State private var recoveryEmailSent = false
        @State private var errorSendingEmail = false
        
        @State private var isTextFieldFocused: Bool = false
        
        var body: some View {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let screenHeight = geometry.size.height
                
                NavigationView {
                    VStack {
                        VStack {
                            CustomTextField(isSecureField: false, textFieldProperty: String(localized: "SignInView_forgot_password_email_label"), textFieldImageName: "envelope", text: $forgotPasswordEmail, isFocusedParentView: $isTextFieldFocused)
                            
                            Text(String(localized: "SignInView_forgot_password_text"))
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                        .padding(.bottom, screenHeight * 0.03)
                        
                        if errorSendingEmail {
                            HStack {
                                LottieView(name: "wrongData", loopMode: .loop, contentMode: .scaleAspectFill)
                                    .frame(width: screenWidth * 0.15, height: screenHeight * 0.05)
                                    .padding(.leading)
                                    .offset(y: -screenHeight * 0.013)
                                Text(String(localized: "SignInView_forgot_password_send_recovery_email_error"))
                                    .foregroundColor(.red)
                                    .font(.system(size: screenWidth * 0.035, weight: .bold))
                                Spacer()
                            }
                            .padding(.horizontal)
                            .offset(x: -screenWidth * 0.006, y: -screenHeight * 0.01)
                        }
                        
                        if recoveryEmailSent {
                            HStack {
                                LottieView(name: "success2", loopMode: .loop, contentMode: .scaleAspectFit)
                                    .frame(width: screenWidth * 0.15, height: screenHeight * 0.05)
                                    .padding(.leading)
                                    .offset(y: -screenHeight * 0.013)
                                Text(String(localized: "SignInView_forgot_password_send_recovery_email_success"))
                                    .foregroundColor(.green)
                                    .font(.system(size: screenWidth * 0.035, weight: .bold))
                                    .offset(y: -screenHeight * 0.01)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                errorSendingEmail = false
                                recoveryEmailSent = false
                                signInViewModel.sendRecoveryEmail(email: forgotPasswordEmail) { success in
                                    if success {
                                        errorSendingEmail = false
                                        recoveryEmailSent = true
                                    } else {
                                        recoveryEmailSent = false
                                        errorSendingEmail = true
                                    }
                                }
                                
                            }
                        }, label: {
                            Text(String(localized: "SignInView_forgot_password_send_recovery_email_button"))
                                .foregroundColor(.white)
                        })
                        .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor(.accentColor))
                        .padding()
                        .disabled(forgotPasswordEmail.isEmpty)
                        .padding(.bottom, screenHeight * 0.02)
                        .offset(y: -screenHeight * 0.05)
                    }
                    .navigationBarTitle(String(localized: "SignInView_forgot_password_navigation_title"), displayMode: .inline)
                }
            }
        }
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
