//
//  SettingsView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @EnvironmentObject private var networkManager: NetworkManager
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
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
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
                        .disabled(!networkManager.isConnected)
                    
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
                        .disabled(!networkManager.isConnected)
                    
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
                        .disabled(!networkManager.isConnected)
                    
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
                        .disabled(!networkManager.isConnected)
                }
                
                Section(header: Text("Help")) {
                    HStack {
                        Text("Version (Build)")
                        Spacer()
                        Text(UIApplication.versionBuild())
                    }
                    
                    NavigationLink("Terms and Conditions", destination: {
                        TermsAndConditionsView()
                    })
                    
                    NavigationLink("Help", destination: {
                        HelpView()
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
    
    struct TermsAndConditionsView: View {
        var body: some View {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let screenHeight = geometry.size.height
                
                VStack(spacing: screenHeight * 0.05) {
                    HStack {
                        Spacer()
                        Text("This app is a fully open-source and licence-free product.")
                            .font(.system(size: screenHeight * 0.03))
                        Spacer()
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 40, style: .continuous))
                .padding(.top, screenHeight * 0.04)
                
                VStack {
                    HStack {
                        Spacer()
                        LottieView(name: "termsAndConditions", loopMode: .loop)
                            .frame(width: screenWidth * 0.9, height: screenHeight * 0.9)
                        Spacer()
                    }
                }
                .padding()
                .padding(.top, screenHeight * 0.15)
                .navigationTitle("Terms and Conditions")
            }
        }
    }
    
    struct HelpView: View {
        var body: some View {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let screenHeight = geometry.size.height
                
                VStack(spacing: screenHeight * 0.05) {
                    HStack {
                        Spacer()
                        Text("In case of any problems please write an e-mail to:")
                            .font(.system(size: screenHeight * 0.03))
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundColor(Color(uiColor: .systemGray5))
                                .frame(width: screenWidth * 0.8, height: screenHeight * 0.07)
                            Text("ljaniszewski00@gmail.com")
                                .font(.system(size: screenHeight * 0.03, weight: .bold))
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        Text("describing the matter.")
                            .font(.system(size: screenHeight * 0.03))
                        Spacer()
                    }
                    
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 40, style: .continuous))
                .padding(.top, screenHeight * 0.04)
                
                VStack {
                    HStack {
                        Spacer()
                        LottieView(name: "help", loopMode: .loop)
                            .frame(width: screenWidth * 0.9, height: screenHeight * 0.9)
                        Spacer()
                    }
                }
                .padding()
                .padding(.top, screenHeight * 0.15)
                .navigationTitle("Help")
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
                    
                    LottieView(name: "delete", loopMode: .loop)
                        .frame(width: screenWidth, height: screenHeight * 0.4)
                    
                    Button(action: {
                        withAnimation {
                            profileViewModel.deleteUserData(email: email, password: password) {
                                print("Successfully deleted user.")
                                dismiss()
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
                    
                    LottieView(name: "changeArrows", loopMode: .loop)
                        .frame(width: screenWidth * 0.3, height: screenHeight * 0.3)
                    
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
                    
                    LottieView(name: "changeArrows", loopMode: .loop)
                        .frame(width: screenWidth * 0.3, height: screenHeight * 0.3)
                    
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
