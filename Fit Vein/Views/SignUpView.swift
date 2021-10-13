//
//  SignUpView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 12/10/2021.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var sessionStore: SessionStore
    
    @State private var firstName = ""
    @State private var username = ""
    
    private var genderValues = ["Man", "Woman"]
    
    @State private var gender = ""
    @State private var birthDate = Date()
    
    @State private var country: Country = .poland
    @State private var city: City = .łódź
    @State private var language: Language = .polish
    
    @State private var correctData = false
    
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
                Group {
                    HStack {
                        Text("Personal Information").font(.title)
                        Spacer()
                    }
                    .padding()
                    
                    
                    VStack {
                        HStack {
                            Text("First Name")
                            Spacer()
                        }
                        
                        TextField("First Name", text: $firstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }
                    .padding()
                    
                    VStack {
                        HStack {
                            Text("Username")
                            Spacer()
                        }
                        
                        TextField("Username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }
                    .padding()
                    
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
                    .padding()
                    
                    VStack {
                        HStack(spacing: screenWidth * 0.2) {
                            Text("Country")
                            Text("City")
                            Text("Language")
                        }
                        
                        HStack(spacing: screenWidth * 0.26) {
                            Picker("Country", selection: $country) {
                                ForEach(Country.allCases) { country in
                                    Text(country.rawValue.capitalized).tag(country)
                                }
                            }
                            
                            Picker("City", selection: $city) {
                                ForEach(City.allCases) { city in
                                    Text(city.rawValue.capitalized).tag(city)
                                }
                            }
                            
                            Picker("Language", selection: $language) {
                                ForEach(Language.allCases) { language in
                                    Text(language.rawValue.capitalized).tag(language)
                                }
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    NavigationLink("Next", destination: SecondSignUpView(firstName: firstName, username: username, gender: gender, birthDate: birthDate, country: country, city: city, language: language).environmentObject(sessionStore).ignoresSafeArea(.keyboard))
                        .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor(checkFieldsNotEmpty() ? .green : .gray))
                        .padding()
                        .disabled(!checkFieldsNotEmpty())
                }
                
                
            }
            .navigationTitle("Sign Up")
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
    
    private var firstName: String
    private var username: String
    private var gender: String
    private var birthDate: Date
    
    private var country: Country
    private var city: City
    private var language: Language
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var repeatedPassword: String = ""
    
    @State private var correctData = false
    
    init(firstName: String, username: String, gender: String, birthDate: Date, country: Country, city: City, language: Language) {
        self.firstName = firstName
        self.username = username
        self.gender = gender
        self.birthDate = birthDate
        self.country = country
        self.city = city
        self.language = language
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                HStack {
                    Text("Account Credentials").font(.title)
                    Spacer()
                }
                .padding()
                
                VStack {
                    HStack {
                        Text("E-mail")
                        Spacer()
                    }
                    
                    TextField("E-mail", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    HStack {
                        Image(systemName: "envelope")
                        Text("Please make sure you provide valid e-mail address").font(.system(size: screenWidth * 0.04))
                        Spacer()
                    }
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
                        Image(systemName: "lock.open")
                        Text("Password should be at least 8 characters long and should contain a number.\n").font(.system(size: screenWidth * 0.04))
                        Spacer()
                    }
                }
                .padding()
                
                VStack {
                    HStack {
                        Text("Confirm Password")
                        Spacer()
                    }
                    
                    SecureField("Confirm Password", text: $repeatedPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    HStack {
                        Image(systemName: "arrow.up.square")
                        Text("Both passwords should be identical.\n").font(.system(size: screenWidth * 0.04))
                        Spacer()
                    }
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    if !email.isEmpty && !password.isEmpty {
                        signUpViewModel.signUp(firstName: firstName, userName: username, birthDate: birthDate, country: country.rawValue, city: city.rawValue, language: language.rawValue, email: email, password: password, gender: gender)
                    }
                }, label: {
                    Text("Sign Up")
                        .fontWeight(.bold)
                })
                .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor(checkDataIsCorrect() ? .green : .gray))
                .padding()
                .disabled(!checkDataIsCorrect())
            }
            .onAppear {
                self.signUpViewModel.setup(sessionStore: sessionStore)
            }
            .navigationTitle("Sign Up")
            .foregroundColor(.white)
            .background(Image("SignUpBackgroundImage")
                            .resizable()
                            .ignoresSafeArea()
                            .scaledToFill())
            
        }
    }
    
    private func displayCredentialsErrors() -> Text {
        let emailError = String("Please make sure the email is correct.\n")
        let passwordError = String("Please make sure your password is at least 8 characters long and contains a number.\n")
        let passwordsMatchError = String("Please make sure both passwords are identical.\n")
        
        if !checkEmail() && !checkPassword() {
            return Text(emailError + passwordError).foregroundColor(.red)
        } else if !checkEmail() {
            return Text(emailError).foregroundColor(.red)
        } else if !checkPassword() {
            return Text(passwordError).foregroundColor(.red)
        } else if !checkBothPasswords() {
            return Text(passwordsMatchError).foregroundColor(.red)
        } else {
            return Text("")
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
        return checkEmail() && checkPassword() && checkBothPasswords()
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                let country: Country = .poland
                let city: City = .łódź
                let language: Language = .polish
                let sessionStore = SessionStore()
                
                SignUpView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
                SecondSignUpView(firstName: "firstName", username: "userName", gender: "gender", birthDate: Date(), country: country, city: city, language: language)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
            }
        }
    }
}
