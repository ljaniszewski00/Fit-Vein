//
//  SignUpView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 12/10/2021.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var sessionStore: SessionStore
    
    
    @State private var firstName = ""
    @State private var username = ""
    
    private var genderValues = ["Man", "Woman"]
    
    @State private var gender = ""
    @State private var birthDate = Date()
    @State private var age = 0
    
    @State var country: Country = .poland
    @State var city: City = .łódź
    @State var language: Language = .polish
    
    @State private var email: String = ""
    @State private var password: String = ""
    
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
            
            ScrollView(.vertical) {
                Group {
                    VStack {
                        HStack {
                            Text("First Name")
                            Spacer()
                        }
                        
                        TextField("", text: $firstName)
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
                        
                        TextField("", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }
                    .padding()
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(genderValues, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    VStack {
                        HStack {
                            Text("Birth Date")
                            Spacer()
                        }
                        
                        DatePicker("Birth Date", selection: $birthDate, in: dateRange, displayedComponents: [.date])
                            .datePickerStyle(WheelDatePickerStyle())
                            .background(RoundedRectangle(cornerRadius: 30).stroke(Color.white, lineWidth: 1))
                            .labelsHidden()
                    }
                    .padding()
                }
                
                
                Spacer()
                
                
                Group {
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
                        Text("Sign Up")
                            .fontWeight(.bold)
                    })
                    .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor(.green))
                    .padding()
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
    
    private func displayCredentialsErrors() -> Text {
        let emailError = String("Please make sure the email is correct.\n")
        let passwordError = String("Please make sure your password is at least 8 characters long and contains a number.\n")
        
        if !checkEmail() && !checkPassword() {
            return Text(emailError + passwordError).foregroundColor(.red)
        } else if !checkEmail() {
            return Text(emailError).foregroundColor(.red)
        } else if !checkPassword() {
            return Text(passwordError).foregroundColor(.red)
        } else {
            return Text("")
        }
    }
    
    private func checkFieldsNotEmpty() -> Bool {
        if firstName.isEmpty || gender.isEmpty {
            return false
        } else {
            return true
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
    
    private func checkDataIsCorrect() -> Bool {
        if checkFieldsNotEmpty() && checkEmail() && checkPassword() {
            return true
        } else {
            return false
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                SignUpView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
