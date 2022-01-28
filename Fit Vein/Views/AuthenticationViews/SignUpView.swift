//
//  SignUpView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 12/10/2021.
//
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var sessionStore: SessionStore
    @StateObject private var signUpViewModel = SignUpViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    @State private var firstName = ""
    @State private var username = ""
    
    private var genderValues = ["Man", "Woman"]
    
    @State private var gender = ""
    @State private var birthDate = Date()
    
    @State private var country: Country = .poland
    @State private var language: Language = .polish
    
    @State private var correctData = false
    
    @State private var usernameTaken = false
    
    @State private var isFirstNameTextFieldFocused: Bool = false
    @State private var isUsernameTextFieldFocused: Bool = false
    
    private let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 1900, month: 1, day: 1)
        let endComponents = DateComponents(year: calendar.dateComponents([.year], from: calendar.date(byAdding: .year, value: -18, to: Date()) ?? Date()).year, month: calendar.dateComponents([.month], from: calendar.date(byAdding: .year, value: -18, to: Date()) ?? Date()).month, day: calendar.dateComponents([.day], from: calendar.date(byAdding: .year, value: -18, to: Date()) ?? Date()).day)
        return calendar.date(from:startComponents)!
            ...
            calendar.date(from:endComponents)!
    }()
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                VStack {
                    Group {
                        HStack {
                            Image(uiImage: UIImage(named: colorScheme == .dark ? "FitVeinIconDark" : "FitVeinIconLight")!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: screenWidth * 0.12, height: screenHeight * 0.12)
                                .padding(.leading, screenWidth * 0.13)
                            
                            Spacer()
                            
                            Text(String(localized: "SignUpView_sign_up_form_label"))
                                .font(.system(size: screenHeight * 0.04, weight: .bold))
                            
                            Spacer()
                        }
                        .padding(.top, screenHeight * 0.02)
                        
                        CustomTextField(textFieldProperty: String(localized: "SignUpView_first_name_label"), textFieldImageName: "person", text: $firstName, isFocusedParentView: $isFirstNameTextFieldFocused)
                            .padding(.bottom, -screenHeight * 0.04)
                        
                        CustomTextField(textFieldProperty: String(localized: "SignUpView_username_label"), textFieldImageName: "person", text: $username, isFocusedParentView: $isUsernameTextFieldFocused)
                            .onChange(of: username) { [signUpViewModel] newValue in
                                Task {
                                    self.usernameTaken = try await signUpViewModel.checkUsernameDuplicate(username: newValue)
                                }
                            }
                        
                        if usernameTaken {
                            HStack(alignment: .center) {
                                LottieView(name: "wrongData", loopMode: .loop, contentMode: .scaleAspectFill)
                                    .frame(width: screenWidth * 0.15, height: screenHeight * 0.05)
                                    .padding(.leading)
                                Text(String(localized: "SignUpView_username_used_label"))
                                    .foregroundColor(.red)
                                    .font(.system(size: screenWidth * 0.04, weight: .bold))
                                Spacer()
                            }
                        }
                        
                        VStack {
                            HStack {
                                Text(String(localized: "SignUpView_gender_label"))
                                Spacer()
                            }
                            
                            Picker(String(localized: "SignUpView_gender_label"), selection: $gender) {
                                ForEach(genderValues, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .padding()
                    }
                    
                    Group {
                        VStack {
                            HStack {
                                Text(String(localized: "SignUpView_birth_date_label"))
                                Spacer()
                            }
                            
                            HStack {
                                DatePicker(String(localized: "SignUpView_birth_date_label"), selection: $birthDate, in: dateRange, displayedComponents: [.date])
                                    .labelsHidden()
                                Spacer()
                            }
                            
                            
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading) {
                            HStack(spacing: screenWidth * 0.2) {
                                Spacer()
                                Text(String(localized: "SignUpView_country_label"))
                                Text(String(localized: "SignUpView_language_label"))
                                Spacer()
                            }
                            
                            HStack(spacing: screenWidth * 0.2) {
                                Spacer()
                                Picker(String(localized: "SignUpView_country_label"), selection: $country) {
                                    ForEach(Country.allCases) { country in
                                        switch country {
                                        case .poland:
                                            Text(String(localized: "SignUpView_country_poland")).tag(country)
                                        }
                                    }
                                }
                                
                                Picker(String(localized: "SignUpView_language_label"), selection: $language) {
                                    ForEach(Language.allCases) { language in
                                        switch language {
                                        case .english:
                                            Text(String(localized: "SignUpView_language_english")).tag(language)
                                        case .polish:
                                            Text(String(localized: "SignUpView_language_polish")).tag(language)
                                        }
                                    }
                                }
                                Spacer()
                            }
                        }
                        .padding(.top)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    NavigationLink(String(localized: "SignUpView_next_button_label"), destination: withAnimation {
                        SecondSignUpView(firstName: firstName, username: username, gender: gender, birthDate: birthDate, country: country, language: language).environmentObject(sessionStore).ignoresSafeArea(.keyboard)
                    })
                        .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor((!checkFieldsNotEmpty() || usernameTaken) ? .gray : .accentColor))
                        .padding()
                        .disabled(!checkFieldsNotEmpty() || usernameTaken)
                    
                    Spacer()
                }
                .background(RoundedRectangle(cornerRadius: 25)
                                .foregroundColor(.black.opacity(0.7))
                                .frame(width: screenWidth * 0.98, height: screenHeight))
                
            }
            .foregroundColor(.white)
            .background(Image("SignUpBackgroundImage")
                            .resizable()
                            .ignoresSafeArea()
                            .scaledToFill())
        }
        
    }
    
    private func checkFieldsNotEmpty() -> Bool {
        if firstName.isEmpty || username.isEmpty || gender.isEmpty {
            return false
        } else {
            return true
        }
    }
}

struct SecondSignUpView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @StateObject private var signUpViewModel = SignUpViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isEmailTextFieldFocused: Bool = false
    @State private var isPasswordTextFieldFocused: Bool = false
    @State private var isRepeatedPasswordTextFieldFocused: Bool = false
    
    private var firstName: String
    private var username: String
    private var gender: String
    private var birthDate: Date
    
    private var country: Country
    private var language: Language
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var repeatedPassword: String = ""
    
    @State private var emailTaken = false
    
    @State private var correctData = false
    
    @State private var errorSigningUp = false
    
    @State private var showPasswordHelp = false
    
    init(firstName: String, username: String, gender: String, birthDate: Date, country: Country, language: Language) {
        self.firstName = firstName
        self.username = username
        self.gender = gender
        self.birthDate = birthDate
        self.country = country
        self.language = language
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                HStack {
                    Image(uiImage: UIImage(named: colorScheme == .dark ? "FitVeinIconDark" : "FitVeinIconLight")!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenWidth * 0.12, height: screenHeight * 0.12)
                        .padding(.leading, screenWidth * 0.13)
                    
                    Spacer()
                    
                    Text(String(localized: "SignUpView_sign_up_form_label"))
                        .font(.system(size: screenHeight * 0.04, weight: .bold))
                    
                    Spacer()
                }
                .padding(.top, screenHeight * 0.02)
                
                CustomTextField(textFieldProperty: String(localized: "SignUpView_email_label"), textFieldImageName: "envelope", text: $email, isFocusedParentView: $isEmailTextFieldFocused)
                    .onChange(of: email) { [signUpViewModel] newValue in
                        Task {
                            self.emailTaken = try await signUpViewModel.checkEmailDuplicate(email: newValue)
                        }
                    }
                
                if emailTaken {
                    HStack(alignment: .center) {
                        LottieView(name: "wrongData", loopMode: .loop, contentMode: .scaleAspectFill)
                            .frame(width: screenWidth * 0.15, height: screenHeight * 0.05)
                            .padding(.leading)
                        Text(String(localized: "SignUpView_email_used_label"))
                            .foregroundColor(.red)
                            .font(.system(size: screenWidth * 0.04, weight: .bold))
                        Spacer()
                    }
                }
                
                CustomTextField(isSecureField: true, textFieldProperty: String(localized: "SignUpView_password_label"), textFieldImageName: "lock", text: $password, isFocusedParentView: $isPasswordTextFieldFocused)
                
                HStack {
                    Button(action: {
                        withAnimation(.linear) {
                            showPasswordHelp.toggle()
                        }
                    }, label: {
                        Image(systemName: "questionmark.circle")
                            .padding()
                            .offset(y: -screenHeight * 0.01)
                    })
                
                    Text(String(localized: "SignUpView_password_hint_label")).font(.caption).fontWeight(.bold)
                        .isHidden(!showPasswordHelp)
                    Spacer()
                }
                .foregroundColor(checkPassword() ? .green : .red)
                .padding()
                .offset(y: -screenHeight * 0.03)
                
                CustomTextField(isSecureField: true, textFieldProperty: String(localized: "SignUpView_repeat_password_label"), textFieldImageName: "lock", text: $repeatedPassword, isFocusedParentView: $isRepeatedPasswordTextFieldFocused)
                    .offset(y: -screenHeight * 0.07)
                
                if errorSigningUp {
                    HStack(alignment: .center) {
                        LottieView(name: "wrongData", loopMode: .loop, contentMode: .scaleAspectFill)
                            .frame(width: screenWidth * 0.15, height: screenHeight * 0.05)
                            .padding(.leading)
                        Text(String(localized: "SignUpView_error"))
                            .foregroundColor(.red)
                            .font(.system(size: screenWidth * 0.04, weight: .bold))
                        Spacer()
                    }
                    .padding(.bottom, screenHeight * 0.03)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        signUpViewModel.signUp(firstName: firstName, userName: username, birthDate: birthDate, country: country.rawValue, language: language.rawValue, email: email, password: password, gender: gender) { success in
                            self.errorSigningUp = !success
                        }
                    }
                }, label: {
                    Text(String(localized: "SignUpView_sign_up_button_label"))
                        .fontWeight(.bold)
                })
                .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor((!checkDataIsCorrect()) ? .gray : .accentColor))
                .padding()
                .disabled(!checkDataIsCorrect())
                .offset(y: -screenHeight * 0.07)
                
                Spacer()
            }
            .background(RoundedRectangle(cornerRadius: 25)
                            .foregroundColor(.black.opacity(0.7))
                            .frame(width: screenWidth * 0.98, height: screenHeight))
            .foregroundColor(.white)
            .background(Image("SignUpBackgroundImage")
                            .resizable()
                            .ignoresSafeArea()
                            .scaledToFill())
            .onTapGesture {
                isEmailTextFieldFocused = false
                isPasswordTextFieldFocused = false
                isRepeatedPasswordTextFieldFocused = false
                UIApplication.shared.endEditing()
            }
        }
    }
    
    private func checkEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }

    private func checkPassword() -> Bool {
        let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    private func checkBothPasswords() -> Bool {
        return password == repeatedPassword
    }
    
    private func checkDataIsCorrect() -> Bool {
        return !email.isEmpty && !password.isEmpty && checkEmail() && checkPassword() && checkBothPasswords() && !emailTaken
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                let country: Country = .poland
                let language: Language = .polish
                let sessionStore = SessionStore(forPreviews: true)
                
                SignUpView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
                SecondSignUpView(firstName: "firstName", username: "userName", gender: "gender", birthDate: Date(), country: country, language: language)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
            }
        }
    }
}
