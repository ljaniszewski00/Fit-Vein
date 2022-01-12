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
                            
                            Text("Sign Up Form")
                                .font(.system(size: screenHeight * 0.04, weight: .bold))
                            
                            Spacer()
                        }
                        
                        CustomTextField(textFieldProperty: "First Name", textFieldImageName: "person", text: $firstName, isFocusedParentView: $isFirstNameTextFieldFocused)
                            .padding(.bottom, -screenHeight * 0.04)
                        
                        CustomTextField(textFieldProperty: "Username", textFieldImageName: "person", text: $username, isFocusedParentView: $isUsernameTextFieldFocused)
                            .onChange(of: username) { [signUpViewModel] newValue in
                                Task {
                                    self.usernameTaken = try await signUpViewModel.checkUsernameDuplicate(username: newValue)
                                }
                            }
                        
                        if usernameTaken {
                            HStack {
                                LottieView(name: "wrongData", loopMode: .loop, contentMode: .scaleAspectFill)
                                    .frame(width: screenWidth * 0.15, height: screenHeight * 0.05)
                                    .padding(.leading)
                                    .offset(y: -screenHeight * 0.013)
                                Text("This username has already been used.\n")
                                    .foregroundColor(.red)
                                    .font(.system(size: screenWidth * 0.04, weight: .bold))
                                Spacer()
                            }
                            .padding(.bottom, -screenHeight * 0.022)
                        }
                        
                        VStack {
                            HStack {
                                Text("Gender")
                                Spacer()
                            }
                            
                            Picker("Gender", selection: $gender) {
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
                                Text("Birth Date")
                                Spacer()
                            }
                            
                            HStack {
                                DatePicker("Birth Date", selection: $birthDate, in: dateRange, displayedComponents: [.date])
                                    .labelsHidden()
                                Spacer()
                            }
                            
                            
                        }
                        .padding(.horizontal)
                        
                        VStack {
                            HStack(spacing: screenWidth * 0.2) {
                                Text("Country")
                                Text("Language")
                            }
                            
                            HStack(spacing: screenWidth * 0.26) {
                                Picker("Country", selection: $country) {
                                    ForEach(Country.allCases) { country in
                                        Text(country.rawValue.capitalized).tag(country)
                                    }
                                }
                                
                                Picker("Language", selection: $language) {
                                    ForEach(Language.allCases) { language in
                                        Text(language.rawValue.capitalized).tag(language)
                                    }
                                }
                            }
                        }
                        .padding(.top)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    NavigationLink("Next", destination: withAnimation {
                        SecondSignUpView(firstName: firstName, username: username, gender: gender, birthDate: birthDate, country: country, language: language).environmentObject(sessionStore).ignoresSafeArea(.keyboard)
                    })
                        .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor((!checkFieldsNotEmpty() || usernameTaken) ? .gray : .accentColor))
                        .padding()
                        .disabled(!checkFieldsNotEmpty() || usernameTaken)
                    
                    Spacer()
                }
                .background(RoundedRectangle(cornerRadius: 25)
                                .foregroundColor(.black.opacity(0.7))
                                .frame(width: screenWidth * 0.98, height: screenHeight * 0.96))
                
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
                    
                    Text("Sign Up Form")
                        .font(.system(size: screenHeight * 0.04, weight: .bold))
                    
                    Spacer()
                }
                
                CustomTextField(textFieldProperty: "E-Mail", textFieldImageName: "envelope", text: $email, isFocusedParentView: $isEmailTextFieldFocused)
                    .onChange(of: email) { [signUpViewModel] newValue in
                        Task {
                            self.emailTaken = try await signUpViewModel.checkEmailDuplicate(email: newValue)
                        }
                    }
                
                if emailTaken {
                    HStack {
                        LottieView(name: "wrongData", loopMode: .loop, contentMode: .scaleAspectFill)
                            .frame(width: screenWidth * 0.15, height: screenHeight * 0.05)
                            .padding(.leading)
                            .offset(y: -screenHeight * 0.013)
                        Text("This email has already been used.\n")
                            .foregroundColor(.red)
                            .font(.system(size: screenWidth * 0.04, weight: .bold))
                        Spacer()
                    }
                    .padding(.bottom, -screenHeight * 0.022)
                }
                
                CustomTextField(isSecureField: true, textFieldProperty: "Password", textFieldImageName: "lock", text: $password, isFocusedParentView: $isPasswordTextFieldFocused)
                
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
                
                    Text("Password should be at least 8 characters long and should contain a number.\n").font(.caption).fontWeight(.bold)
                        .isHidden(!showPasswordHelp)
                    Spacer()
                }
                .foregroundColor(checkPassword() ? .green : .red)
                .padding()
                .offset(y: -screenHeight * 0.03)
                
                CustomTextField(isSecureField: true, textFieldProperty: "Repeat Password", textFieldImageName: "lock", text: $repeatedPassword, isFocusedParentView: $isRepeatedPasswordTextFieldFocused)
                    .offset(y: -screenHeight * 0.07)
                
                if errorSigningUp {
                    HStack {
                        LottieView(name: "wrongData", loopMode: .loop, contentMode: .scaleAspectFill)
                            .frame(width: screenWidth * 0.15, height: screenHeight * 0.05)
                            .padding(.leading)
                            .offset(y: -screenHeight * 0.013)
                        Text("Error signing up. Please try again later.\n")
                            .foregroundColor(.red)
                            .font(.system(size: screenWidth * 0.04, weight: .bold))
                        Spacer()
                    }
                    .padding(.bottom, -screenHeight * 0.022)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        signUpViewModel.signUp(firstName: firstName, userName: username, birthDate: birthDate, country: country.rawValue, language: language.rawValue, email: email, password: password, gender: gender) { success in
                            self.errorSigningUp = !success
                        }
                    }
                }, label: {
                    Text("Sign Up")
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
                            .frame(width: screenWidth * 0.98, height: screenHeight * 0.95))
            .foregroundColor(.white)
            .background(Image("SignUpBackgroundImage")
                            .resizable()
                            .ignoresSafeArea()
                            .scaledToFill())
            
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
