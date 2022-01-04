//
//  SettingsView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @StateObject private var sheetManager = SheetManager()
    @State private var shouldPresentActionSheet = false
    @AppStorage("locked") var biometricLock: Bool = false
    @AppStorage("notifications") var notifications: Bool = true
    @AppStorage("showSampleWorkoutsListFromSettings") var showSampleWorkoutsListFromSettings: Bool = true
    @Environment(\.colorScheme) var colorScheme
    
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
    
    var body: some View {
        GeometryReader { geometry in
            
            Form {
                Section(header: Text("App"), footer: Text("Whether FaceID or TouchID is used depends on device hardware capabilities.")) {
                    Toggle(isOn: $notifications, label: {
                        Image(systemName: "bell.circle.fill")
                            .font(.title)
                            .foregroundColor(.accentColor)
                        Text("Notifications")
                    })
                    
                    Toggle(isOn: $showSampleWorkoutsListFromSettings, label: {
                        Image(systemName: "list.bullet.circle.fill")
                            .font(.title)
                            .foregroundColor(.accentColor)
                        Text("Show 'Sample Workouts' in Workouts Tab")
                    })
                    
                    Toggle(isOn: $biometricLock, label: {
                        Image(systemName: "faceid")
                            .font(.title)
                            .foregroundColor(.accentColor)
                        Text("Use FaceID / TouchID")
                    })
                }
                
                Section(header: Text("Account")) {
                    Button(action: {
                        sheetManager.whichSheet = .email
                        sheetManager.showSheet.toggle()
                    }, label: {
                        HStack {
                            Image(systemName: "envelope.circle.fill")
                                .font(.title)
                                .foregroundColor(.accentColor)
                            Text("Change e-mail address")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    })
                    
                    Button(action: {
                        sheetManager.whichSheet = .password
                        sheetManager.showSheet.toggle()
                    }, label: {
                        HStack {
                            Image(systemName: "lock.circle.fill")
                                .font(.title)
                                .foregroundColor(.accentColor)
                            Text("Change password")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    })
                    
                    Button(action: {
                        sheetManager.whichSheet = .logout
                        shouldPresentActionSheet = true
                    }, label: {
                        HStack {
                            Image(systemName: "person.crop.circle.fill.badge.minus")
                                .font(.title)
                                .foregroundColor(.accentColor)
                            Text("Logout")
                                .foregroundColor(.red)
                        }
                    })
                    
                    Button(action: {
                        sheetManager.whichSheet = .signout
                        shouldPresentActionSheet = true
                    }, label: {
                        HStack {
                            Image(systemName: "trash.circle.fill")
                                .font(.title)
                                .foregroundColor(.accentColor)
                            Text("Delete account")
                                .foregroundColor(.red)
                        }
                    })
                }
                
                Section(header: Text("Help")) {
                    HStack {
                        Text("Version (Build)")
                        Spacer()
                        Text(UIApplication.versionBuild())
                    }
                    
                    NavigationLink("Terms and Conditions", destination: {
                        VStack(alignment: .leading) {
                            Text("This app is a fully open-source and licence-free product so everyone has right to watch, rewrite, copy and publish every part of that app.")
                            Spacer()
                        }
                        .padding()
                        .navigationTitle("Terms and Conditions")
                    })
                    
                    NavigationLink("Help", destination: {
                        VStack(alignment: .leading) {
                            Text("In case of any problem please write an e-mail to:")
                            Text("ljaniszewski00@gmail.com")
                                .foregroundColor(.accentColor)
                            Text("describing the matter.")
                            Spacer()
                        }
                        .padding()
                        .navigationTitle("Help")
                    })
                    
                    HStack {
                        HStack {
                            Image(systemName: "link.circle.fill")
                                .font(.title)
                                .foregroundColor(.accentColor)
                            Text("Follow me on GitHub:")
                            Link("Vader20FF", destination: URL(string: "https://github.com/Vader20FF")!)
                                .foregroundColor(.accentColor)
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                }
            }
            .navigationBarTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            
            .sheet(isPresented: $sheetManager.showSheet) {
                switch sheetManager.whichSheet {
                case .email:
                    ChangeEmailAddressSheetView().environmentObject(profileViewModel)
                case .password:
                    ChangePasswordSheetView().environmentObject(profileViewModel)
                case .signout:
                    DeleteAccountSheetView().environmentObject(profileViewModel)
                default:
                    Text("No view")
                }
            }
            .confirmationDialog(sheetManager.whichSheet == .logout ? "Are you sure you want to logout?" : "Are you sure you want to delete your account? All data will be lost.", isPresented: $shouldPresentActionSheet, titleVisibility: .visible) {
                if sheetManager.whichSheet == .logout {
                    Button("Logout", role: .destructive) {
                        profileViewModel.sessionStore.signOut()
                        profileViewModel.detachCurrentProfile()
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
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    
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
                                profileViewModel.sessionStore.deleteUser(email: email, password: password) {
                                    print("Successfully deleted user.")
                                }
                            }
                        }
                    }, label: {
                        Text("Delete account permanently")
                    })
                    .frame(width: screenWidth * 0.7, height: screenHeight * 0.08)
                    .background(Color.accentColor)
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
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var oldEmail = ""
    @State private var password = ""
    @State private var newEmail = ""
    
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
                    .background(Color.accentColor)
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
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var oldPassword = ""
    @State private var newPassword = ""
    
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
                    .background(Color.accentColor)
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
                SettingsView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(SessionStore(forPreviews: true))
                    .environmentObject(profileViewModel)
            }
        }
    }
}
