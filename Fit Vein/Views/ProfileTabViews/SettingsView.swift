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
                Section(header: Text(String(localized: "SettingsView_app_settings_section")), footer: Text(String(localized: "SettingsView_faceID_touchID_info_label"))) {
                    Toggle(isOn: $notifications, label: {
                        Image(systemName: "bell.circle.fill")
                            .font(.title)
                            .foregroundColor(.accentColor)
                        Text(String(localized: "SettingsView_notifications_toggle_label"))
                    })
                    
                    Toggle(isOn: $showSampleWorkoutsListFromSettings, label: {
                        Image(systemName: "list.bullet.circle.fill")
                            .font(.title)
                            .foregroundColor(.accentColor)
                        Text(String(localized: "SettingsView_sample_workouts_toggle_label"))
                    })
                    
                    Toggle(isOn: $biometricLock, label: {
                        Image(systemName: "faceid")
                            .font(.title)
                            .foregroundColor(.accentColor)
                        Text(String(localized: "SettingsView_faceID_touchID_toggle_label"))
                    })
                }
                
                Section(header: Text(String(localized: "SettingsView_account_settings_section"))) {
                    Button(action: {
                        sheetManager.whichSheet = .email
                        sheetManager.showSheet.toggle()
                    }, label: {
                        HStack {
                            Image(systemName: "envelope.circle.fill")
                                .font(.title)
                                .foregroundColor(.accentColor)
                            Text(String(localized: "SettingsView_change_email_address_button"))
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
                            Text(String(localized: "SettingsView_change_password_button"))
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
                            Text(String(localized: "SettingsView_logout"))
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
                            Text(String(localized: "SettingsView_delete_account"))
                                .foregroundColor(.red)
                        }
                    })
                        .disabled(!networkManager.isConnected)
                }
                
                Section(header: Text(String(localized: "SettingsView_help_settings_section"))) {
                    HStack {
                        Text(String(localized: "SettingsView_version_label"))
                        Spacer()
                        Text(UIApplication.versionBuild())
                    }
                    
                    NavigationLink(String(localized: "SettingsView_terms_and_conditions_settings_label"), destination: {
                        TermsAndConditionsView()
                    })
                    
                    NavigationLink(String(localized: "SettingsView_help_settings_label"), destination: {
                        HelpView()
                    })
                    
                    HStack {
                        HStack {
                            Image(systemName: "link.circle.fill")
                                .font(.title)
                                .foregroundColor(.accentColor)
                            Text(String(localized: "SettingsView_github_author_following"))
                            Link("Vader20FF", destination: URL(string: "https://github.com/Vader20FF")!)
                                .foregroundColor(.accentColor)
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                }
            }
            .navigationBarTitle(String(localized: "SettingsView_navigation_title"))
            .navigationBarTitleDisplayMode(.large)
            
            .sheet(isPresented: $sheetManager.showSheet) {
                switch sheetManager.whichSheet {
                case .email:
                    ChangeEmailAddressSheetView().environmentObject(profileViewModel).ignoresSafeArea(.keyboard)
                case .password:
                    ChangePasswordSheetView().environmentObject(profileViewModel).ignoresSafeArea(.keyboard)
                case .signout:
                    DeleteAccountSheetView().environmentObject(profileViewModel).ignoresSafeArea(.keyboard)
                default:
                    Text("No view")
                }
            }
            .confirmationDialog(sheetManager.whichSheet == .logout ? String(localized: "SettingsView_logout_confirmation_dialog_text") : String(localized: "SettingsView_delete_account_confirmation_dialog_text"), isPresented: $shouldPresentActionSheet, titleVisibility: .visible) {
                if sheetManager.whichSheet == .logout {
                    Button(String(localized: "SettingsView_logout_confirmation_dialog_logout_button"), role: .destructive) {
                        profileViewModel.sessionStore.signOut()
                        profileViewModel.detachCurrentProfile()
                        dismiss()
                    }
                    Button(String(localized: "SettingsView_logout_confirmation_dialog_cancel_button"), role: .cancel) {}
                } else {
                    Button(String(localized: "SettingsView_delete_account_confirmation_dialog_delete_account_button"), role: .destructive) {
                        sheetManager.showSheet.toggle()
                    }
                    Button(String(localized: "SettingsView_delete_account_confirmation_dialog_cancel_button"), role: .cancel) {}
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
                        Text(String(localized: "SettingsView_terms_and_conditions_text"))
                            .font(.system(size: screenHeight * 0.03))
                        Spacer()
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 40, style: .continuous))
                .padding(.top, screenHeight * 0.04)
                .padding(.horizontal)
                
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
                .navigationTitle(String(localized: "SettingsView_terms_and_conditions_navigation_title"))
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
                        Text(String(localized: "SettingsView_help_text"))
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
                        Text(String(localized: "SettingsView_help_text2"))
                            .font(.system(size: screenHeight * 0.03))
                        Spacer()
                    }
                    
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 40, style: .continuous))
                .padding(.top, screenHeight * 0.04)
                .padding(.horizontal)
                
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
                .navigationTitle(String(localized: "SettingsView_help_navigation_title"))
            }
        }
    }
}

struct DeleteAccountSheetView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var error = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
        
            NavigationView {
                VStack {
                    Form {
                        Section(footer: Text(String(localized: "DeleteAccountSheet_info"))) {
                            TextField(String(localized: "DeleteAccountSheet_email_address"), text: $email)
                                .focused($isTextFieldFocused)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                            SecureField(String(localized: "DeleteAccountSheet_password"), text: $password)
                                .focused($isTextFieldFocused)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                        }
                    }
                    
                    if error {
                        HStack {
                            LottieView(name: "wrongData", loopMode: .loop, contentMode: .scaleAspectFill)
                                .frame(width: screenWidth * 0.15, height: screenHeight * 0.05)
                                .padding(.leading)
                                .offset(y: -screenHeight * 0.013)
                            Text(String(localized: "DeleteAccountSheet_delete_account_error"))
                                .foregroundColor(.red)
                                .font(.system(size: screenWidth * 0.035, weight: .bold))
                            Spacer()
                        }
                        .padding(.horizontal)
                        .offset(y: -screenHeight * 0.05)
                    }
                    
                    LottieView(name: "delete", loopMode: .loop)
                        .frame(width: screenWidth, height: screenHeight * 0.4)
                        .offset(y: isTextFieldFocused ? -screenHeight * 0.3 : 0)
                    
                    Button(action: {
                        withAnimation {
                            error = false
                            profileViewModel.deleteUserData(email: email.lowercased(), password: password) { success in
                                if success {
                                    print("Successfully deleted user.")
                                    dismiss()
                                } else {
                                    error = true
                                }
                            }
                        }
                    }, label: {
                        Text(String(localized: "DeleteAccountSheet_delete_account_button"))
                    })
                    .frame(width: screenWidth * 0.7, height: screenHeight * 0.08)
                    .background(Color.accentColor)
                    .cornerRadius(15.0)
                    .font(.system(size: screenHeight * 0.026))
                    .foregroundColor(.white)
                    .padding()
                    .offset(y: isTextFieldFocused ? -screenHeight * 0.4 : 0)
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
    
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var error = false
    @State private var success = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
        
            NavigationView {
                VStack {
                    Form {
                        Section(footer: Text(String(localized: "ChangeEmailSheet_info"))) {
                            TextField(String(localized: "ChangeEmailSheet_old_email_address"), text: $oldEmail)
                                .focused($isTextFieldFocused)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                            SecureField(String(localized: "ChangeEmailSheet_password"), text: $password)
                                .focused($isTextFieldFocused)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                            TextField(String(localized: "ChangeEmailSheet_new_email_address"), text: $newEmail)
                                .focused($isTextFieldFocused)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                        }
                    }
                    
                    if error {
                        HStack {
                            LottieView(name: "wrongData", loopMode: .loop, contentMode: .scaleAspectFill)
                                .frame(width: screenWidth * 0.15, height: screenHeight * 0.05)
                                .padding(.leading)
                                .offset(y: -screenHeight * 0.013)
                            Text(String(localized: "ChangeEmailSheet_change_email_error"))
                                .foregroundColor(.red)
                                .font(.system(size: screenWidth * 0.035, weight: .bold))
                            Spacer()
                        }
                        .padding(.horizontal)
                        .offset(y: -screenHeight * 0.05)
                    }
                    
                    if success {
                        HStack {
                            LottieView(name: "success2", loopMode: .loop, contentMode: .scaleAspectFit)
                                .frame(width: screenWidth * 0.15, height: screenHeight * 0.05)
                                .padding(.leading)
                                .offset(y: -screenHeight * 0.013)
                            Text(String(localized: "ChangeEmailSheet_change_email_success"))
                                .foregroundColor(.green)
                                .font(.system(size: screenWidth * 0.035, weight: .bold))
                                .offset(y: -screenHeight * 0.01)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    LottieView(name: "changeArrows", loopMode: .loop)
                        .frame(width: screenWidth * 0.3, height: screenHeight * 0.3)
                        .offset(y: isTextFieldFocused ? -screenHeight * 0.35 : 0)
                    
                    Button(action: {
                        withAnimation {
                            error = false
                            success = false
                            profileViewModel.emailAddressChange(oldEmailAddress: oldEmail.lowercased(), password: password, newEmailAddress: newEmail.lowercased()) { success in
                                if success {
                                    print("Successfully changed e-mail address.")
                                    self.success = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        dismiss()
                                    }
                                } else {
                                    error = true
                                }
                            }
                        }
                    }, label: {
                        Text(String(localized: "ChangeEmailSheet_change_email_address_button"))
                    })
                    .frame(width: screenWidth * 0.7, height: screenHeight * 0.08)
                    .background(Color.accentColor)
                    .cornerRadius(15.0)
                    .font(.system(size: screenHeight * 0.026))
                    .foregroundColor(.white)
                    .padding()
                    .offset(y: isTextFieldFocused ? -screenHeight * 0.4 : 0)
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
    
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var error = false
    @State private var success = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
        
            NavigationView {
                VStack {
                    Form {
                        Section(footer: Text(String(localized: "ChangePasswordSheet_info"))) {
                            TextField(String(localized: "ChangePasswordSheet_email_address"), text: $email)
                                .focused($isTextFieldFocused)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                            SecureField(String(localized: "ChangePasswordSheet_old_password"), text: $oldPassword)
                                .focused($isTextFieldFocused)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                            SecureField(String(localized: "ChangePasswordSheet_new_password"), text: $newPassword)
                                .focused($isTextFieldFocused)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                        }
                    }
                    
                    if error {
                        HStack {
                            LottieView(name: "wrongData", loopMode: .loop, contentMode: .scaleAspectFill)
                                .frame(width: screenWidth * 0.15, height: screenHeight * 0.05)
                                .padding(.leading)
                                .offset(y: -screenHeight * 0.013)
                            Text(String(localized: "ChangePasswordSheet_change_password_error"))
                                .foregroundColor(.red)
                                .font(.system(size: screenWidth * 0.035, weight: .bold))
                            Spacer()
                        }
                        .padding(.horizontal)
                        .offset(y: -screenHeight * 0.05)
                    }
                    
                    if success {
                        HStack {
                            LottieView(name: "success2", loopMode: .loop, contentMode: .scaleAspectFit)
                                .frame(width: screenWidth * 0.15, height: screenHeight * 0.05)
                                .padding(.leading)
                                .offset(y: -screenHeight * 0.013)
                            Text(String(localized: "ChangePasswordSheet_change_password_success"))
                                .foregroundColor(.green)
                                .font(.system(size: screenWidth * 0.035, weight: .bold))
                                .offset(y: -screenHeight * 0.01)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    LottieView(name: "changeArrows", loopMode: .loop)
                        .frame(width: screenWidth * 0.3, height: screenHeight * 0.3)
                        .offset(y: isTextFieldFocused ? -screenHeight * 0.35 : 0)
                    
                    Button(action: {
                        withAnimation {
                            error = false
                            success = false
                            profileViewModel.passwordChange(emailAddress: email.lowercased(), oldPassword: oldPassword, newPassword: newPassword) { success in
                                if success {
                                    print("Successfully changed password.")
                                    self.success = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        dismiss()
                                    }
                                } else {
                                    error = true
                                }
                            }
                        }
                    }, label: {
                        Text(String(localized: "ChangePasswordSheet_change_password_button"))
                    })
                    .frame(width: screenWidth * 0.7, height: screenHeight * 0.08)
                    .background(Color.accentColor)
                    .cornerRadius(15.0)
                    .font(.system(size: screenHeight * 0.026))
                    .foregroundColor(.white)
                    .padding()
                    .offset(y: isTextFieldFocused ? -screenHeight * 0.4 : 0)
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
