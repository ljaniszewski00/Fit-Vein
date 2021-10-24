//
//  SettingsView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    
    @StateObject private var sheetManager = SheetManager()
    @State private var shouldPresentActionSheet = false
    
    @Environment(\.dismiss) var dismiss
    
    private class SheetManager: ObservableObject {
        enum Sheet {
            case email
            case password
            case logout
            case signout
        }
        
        @Published var showSheet = false
        @Published var whichSheet: Sheet? = nil
    }
    
    
    init(profile: ProfileViewModel) {
        self.profileViewModel = profile
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
                
            Form {
                Section(header: Text("Chats")) {
                    Toggle(isOn: .constant(false), label: {
                        Text("Hide my activity status")
                    })
                }
                
                Section(header: Text("Account")) {
                    Button(action: {
                        sheetManager.whichSheet = .email
                        sheetManager.showSheet.toggle()
                    }, label: {
                        Text("Change e-mail address")
                    })
                    
                    Button(action: {
                        sheetManager.whichSheet = .password
                        sheetManager.showSheet.toggle()
                    }, label: {
                        Text("Change password")
                    })
                    
                    Button(action: {
                        sheetManager.whichSheet = .logout
                        shouldPresentActionSheet = true
                    }, label: {
                        Text("Logout")
                            .foregroundColor(.red)
                    })
                    
                    Button(action: {
                        sheetManager.whichSheet = .signout
                        shouldPresentActionSheet = true
                    }, label: {
                        Text("Delete account")
                            .foregroundColor(.red)
                    })
                }
                
                Section(header: Text("Additional")) {
                    Label("Follow me on GitHub:", systemImage: "link")
                        .font(.system(size: 17, weight: .semibold))
                    Link("@Vader20FF", destination: URL(string: "https://github.com/Vader20FF")!)
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .navigationBarTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            
            .sheet(isPresented: $sheetManager.showSheet) {
                switch sheetManager.whichSheet {
                case .email:
                    ChangeEmailAddressSheetView(profile: profileViewModel)
                case .password:
                    ChangePasswordSheetView(profile: profileViewModel)
                case .signout:
                    DeleteAccountSheetView(profile: profileViewModel)
                default:
                    Text("No view")
                }
            }
            .confirmationDialog(sheetManager.whichSheet == .logout ? "Are you sure you want to logout?" : "Are you sure you want to delete your account? All data will be lost.", isPresented: $shouldPresentActionSheet, titleVisibility: .visible) {
                if sheetManager.whichSheet == .logout {
                    Button("Logout", role: .destructive) {
                        profileViewModel.sessionStore!.signOut()
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) {}
                } else {
                    Button("Delete Account", role: .destructive) {
                        sheetManager.showSheet.toggle()
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
        }
    }
}

struct DeleteAccountSheetView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    
    init(profile: ProfileViewModel) {
        self.profileViewModel = profile
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
        
            NavigationView {
                VStack {
                    Form {
                        Section(footer: Text("Before you delete your account please provide your login credentials to confirm it is really you.")) {
                            TextField("E-mail", text: $email)
                            SecureField("Password", text: $password)
                        }
                    }
                    
                    Button(action: {
                        withAnimation {
                            dismiss()
                            profileViewModel.deleteUserData() {
                                profileViewModel.sessionStore!.deleteUser(email: email, password: password) {
                                    print("Successfully deleted user.")
                                }
                            }
                        }
                    }, label: {
                        Text("Delete account permanently")
                    })
                    .frame(width: screenWidth * 0.7, height: screenHeight * 0.08)
                    .background(Color.green)
                    .cornerRadius(15.0)
                    .font(.system(size: screenHeight * 0.026))
                    .foregroundColor(.white)
                    .padding()
                }
                .navigationBarHidden(true)
                .ignoresSafeArea(.keyboard)
            }
        }
    }
}


struct ChangeEmailAddressSheetView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var oldEmail = ""
    @State private var password = ""
    @State private var newEmail = ""
    
    init(profile: ProfileViewModel) {
        self.profileViewModel = profile
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
        
            NavigationView {
                VStack {
                    Form {
                        Section(footer: Text("Before you change your e-mail address please provide your login credentials to confirm it is really you.")) {
                            TextField("Old e-mail address", text: $oldEmail)
                            SecureField("Password", text: $password)
                            TextField("New e-mail address", text: $newEmail)
                        }
                    }
                    
                    Button(action: {
                        withAnimation {
                            dismiss()
                            profileViewModel.emailAddressChange(oldEmailAddress: oldEmail, password: password, newEmailAddress: newEmail) {}
                        }
                    }, label: {
                        Text("Change e-mail address")
                    })
                    .frame(width: screenWidth * 0.7, height: screenHeight * 0.08)
                    .background(Color.green)
                    .cornerRadius(15.0)
                    .font(.system(size: screenHeight * 0.026))
                    .foregroundColor(.white)
                    .padding()
                }
                .navigationBarHidden(true)
                .ignoresSafeArea(.keyboard)
            }
        }
    }
}


struct ChangePasswordSheetView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var oldPassword = ""
    @State private var newPassword = ""
    
    init(profile: ProfileViewModel) {
        self.profileViewModel = profile
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
        
            NavigationView {
                VStack {
                    Form {
                        Section(footer: Text("Before you change your password please provide your login credentials to confirm it is really you.")) {
                            TextField("E-mail", text: $email)
                            SecureField("Old password", text: $oldPassword)
                            SecureField("New password", text: $newPassword)
                        }
                    }
                    
                    Button(action: {
                        withAnimation {
                            dismiss()
                            profileViewModel.passwordChange(emailAddress: email, oldPassword: oldPassword, newPassword: newPassword) {}
                        }
                    }, label: {
                        Text("Change password")
                    })
                    .frame(width: screenWidth * 0.7, height: screenHeight * 0.08)
                    .background(Color.green)
                    .cornerRadius(15.0)
                    .font(.system(size: screenHeight * 0.026))
                    .foregroundColor(.white)
                    .padding()
                }
                .navigationBarHidden(true)
                .ignoresSafeArea(.keyboard)
            }
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let profileViewModel = ProfileViewModel(forPreviews: true)
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                SettingsView(profile: profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(SessionStore())
            }
        }
    }
}