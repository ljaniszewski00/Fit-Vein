//
//  ProfileView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @EnvironmentObject private var medalsViewModel: MedalsViewModel
    @EnvironmentObject private var networkManager: NetworkManager
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("shouldShowLevelUpAnimation") var shouldShowLevelUpAnimationTrigger: Bool = false
    @State private var shouldShowLevelUpAnimation: Bool = false
    
    @State private var oldImage = UIImage()
    @State private var image = UIImage()
    
    @State private var shouldPresentAddActionSheet = false
    @State private var shouldPresentImagePicker = false
    @State private var shouldPresentCamera = false
    
    @State private var shouldPresentSettings = false
    
    @State private var tabSelection = 0
    
    @State private var alreadyAppearedOnce = false
    
    @State private var shouldShowMedalsPresentation = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            NavigationView {
                if profileViewModel.profile != nil {
                    withAnimation {
                        ScrollView(.vertical) {
                            HStack {
                                if !networkManager.isConnected {
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            LottieView(name: "noInternetConnection", loopMode: .loop)
                                                .frame(width: screenWidth * 0.3, height: screenHeight * 0.15)
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                } else {
                                    Group {
                                        if let profilePicturePhoto = profileViewModel.profilePicturePhoto {
                                            Image(uiImage: profilePicturePhoto)
                                                .resizable()
                                                .onTapGesture {
                                                    self.shouldPresentAddActionSheet = true
                                                }
                                        } else {
                                            Image(uiImage: UIImage(named: "blank-profile-hi")!)
                                                .resizable()
                                                .shadow(color: .gray, radius: 7)
                                                .onTapGesture {
                                                    self.shouldPresentAddActionSheet = true
                                                }
                                        }
                                    }
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 50))
                                    .frame(width: screenWidth * 0.4, height: screenHeight * 0.2)
                                }
                                
                                
                                Spacer(minLength: screenWidth * 0.05)
                                
                                VStack {
                                    HStack {
                                        Text(profileViewModel.profile!.firstName)
                                            .foregroundColor(.accentColor)
                                            .font(.system(size: screenHeight * 0.03))
                                            .fontWeight(.bold)
                                        
                                        Spacer()
                                        
                                        NavigationLink(destination: SettingsView().environmentObject(profileViewModel).environmentObject(networkManager), isActive: $shouldPresentSettings) {
                                            Button(action: {
                                                withAnimation(.linear) {
                                                    shouldPresentSettings = true
                                                }
                                            }, label: {
                                                Image(systemName: "ellipsis")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .foregroundColor(.accentColor)
                                                    .padding(.trailing, screenWidth * 0.05)
                                            })
                                            .frame(width: screenWidth * 0.12, height: screenHeight * 0.04)
                                        }
                                    }
                                    .padding(.top, screenHeight * 0.02)
                                    
                                    HStack {
                                        Text(profileViewModel.profile!.username)
                                            .foregroundColor(Color(uiColor: UIColor.lightGray))
                                        Spacer()
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(alignment: .center, spacing: screenWidth * 0.03) {
                                        if medalsViewModel.allUsersMedals.count != 0 {
                                            ForEach(medalsViewModel.allUsersMedals[medalsViewModel.allUsersMedals.count < 3 ? 0...(medalsViewModel.allUsersMedals.count - 1) : 0...2], id: \.self) { medalFileName in
                                                Image(uiImage: UIImage(named: medalFileName)!)
                                                    .resizable()
                                                    .shadow(color: .gray, radius: 3)
                                                    .frame(width: screenWidth * 0.14, height: screenHeight * 0.07)
                                                    .onTapGesture {
                                                        withAnimation(.linear) {
                                                            shouldShowMedalsPresentation = true
                                                        }
                                                    }
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .padding()
                            
                            VStack {
                                Text("\(String(localized: "ProfileView_level_label")) \(self.profileViewModel.profile!.level)")
                                    .font(.system(size: screenHeight * 0.03))
                                    .fontWeight(.bold)
                                
                                RoundedRectangle(cornerRadius: 25)
                                    .frame(width: screenWidth * 0.9)
                                    .padding()
                                    .overlay(
                                        HStack {
                                            RoundedRectangle(cornerRadius: 25)
                                                .foregroundColor(.accentColor)
                                                .padding()
                                                .frame(width: screenWidth * CGFloat(getWorkoutsDivider(workoutsCount: self.profileViewModel.calculateUserCompletedWorkoutsForCurrentLevel())) / CGFloat(self.profileViewModel.calculateUserMaxWorkoutsForLevel()))
                                            
                                            Spacer()
                                        }
                                    )
                                    .foregroundColor(Color(UIColor.systemGray5))
                                    .shadow(color: .gray, radius: 7)
                                
                                Text("\(self.profileViewModel.calculateUserCompletedWorkoutsForCurrentLevel()) / \(self.profileViewModel.calculateUserMaxWorkoutsForLevel()) \(String(localized: "ProfileView_workouts_label"))")
                                
                                Spacer(minLength: screenHeight * 0.05)
                                
                                Picker("", selection: $tabSelection) {
                                    Image(systemName: "heart.fill").tag(0)
                                    Image(systemName: "figure.walk").tag(1)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                
                                if tabSelection == 0 {
                                    HealthTabView()
                                        .frame(height: screenHeight)
                                } else {
                                    if self.profileViewModel.workouts == nil {
                                        VStack() {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 30)
                                                    .foregroundColor(Color(UIColor.systemGray5))
                                                    .frame(width: screenWidth * 0.95, height: screenHeight * 0.2)
                                                
                                                Text(String(localized: "ProfileView_no_workouts_message"))
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.accentColor)
                                                    .frame(width: screenWidth * 0.8)
                                            }
                                            .padding(.top, screenHeight * 0.1)
                                            
                                            LottieView(name: "downArrows", loopMode: .loop)
                                                .frame(width: screenWidth * 0.25, height: screenHeight * 0.2)
                                            
                                            Spacer()
                                        }
                                        
                                    } else {
                                        WorkoutTabView().environmentObject(profileViewModel)
                                            .frame(height: screenHeight)
                                    }
                                }
                            }
                        }
                        .if(shouldShowLevelUpAnimation) {
                            $0
                                .blur(radius: 5)
                                .overlay(
                                    VStack(spacing: 0) {
                                        Spacer()
                                        LottieView(name: "levelUp", loopMode: .playOnce, contentMode: .scaleAspectFill)
                                            .frame(width: screenWidth * 0.5, height: screenHeight * 0.5)
                                            .padding(.top, -screenHeight * 0.2)
                                        Text(String(localized: "ProfileView_level_up"))
                                            .font(.system(size: screenHeight * 0.1, weight: .bold))
                                            .foregroundColor(.green)
                                            .offset(y: -screenHeight * 0.14)
                                        Spacer()
                                    }
                                    .onAppear {
                                        withAnimation {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                UserDefaults.standard.set(false, forKey: "shouldShowLevelUpAnimation")
                                                self.shouldShowLevelUpAnimation = false
                                            }
                                        }
                                    }
                                    .onTapGesture {
                                        withAnimation {
                                            UserDefaults.standard.set(false, forKey: "shouldShowLevelUpAnimation")
                                            self.shouldShowLevelUpAnimation = false
                                        }
                                    }
                                )
                        }
                        .if(shouldShowMedalsPresentation && medalsViewModel.allUsersMedals.count != 0) {
                            $0
                                .overlay(
                                    TabView {
                                        ForEach(medalsViewModel.allUsersMedals, id: \.self) { medalFileName in
                                            VStack(spacing: screenHeight * 0.07) {
                                                Image(uiImage: UIImage(named: medalFileName)!)
                                                    .resizable()
                                                    .frame(width: screenWidth * 0.56, height: screenHeight * 0.28)

                                                Text(medalsViewModel.allMedalsDescriptions[medalFileName]!)
                                                    .font(.system(size: screenHeight * 0.025, weight: .bold))
                                            }
                                        }
                                    }
                                        .tabViewStyle(PageTabViewStyle())
                                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 40, style: .continuous))
                                        .onTapGesture {
                                            withAnimation(.linear) {
                                                shouldShowMedalsPresentation = false
                                            }
                                        }
                                )
                        }
                        .onAppear {
                            withAnimation {
                                self.shouldShowLevelUpAnimation = self.shouldShowLevelUpAnimationTrigger
                            }
                        }
                        .navigationTitle("")
                        .navigationBarHidden(true)
                        .sheet(isPresented: $shouldPresentImagePicker) {
                            ImagePicker(sourceType: self.shouldPresentCamera ? .camera : .photoLibrary, selectedImage: self.$image)
                                .onDisappear {
                                    if !self.image.isEqual(self.oldImage) {
                                        self.oldImage = image
                                        profileViewModel.uploadPhoto(image: image) { success in }
                                    }
                                }
                        }
                        .actionSheet(isPresented: $shouldPresentAddActionSheet) {
                            ActionSheet(title: Text(String(localized: "ProfileView_change_photo_confirmation_dialog_text")), message: nil, buttons: [
                                .default(Text(String(localized: "ProfileView_change_photo_confirmation_dialog_take_photo_button")), action: {
                                     self.shouldPresentImagePicker = true
                                     self.shouldPresentCamera = true
                                 }),
                                .default(Text(String(localized: "ProfileView_change_photo_confirmation_dialog_upload_photo_button")), action: {
                                     self.shouldPresentImagePicker = true
                                     self.shouldPresentCamera = false
                                 }),
                                .cancel(Text(String(localized: "ProfileView_change_photo_confirmation_dialog_cancel_button")))
                            ])
                        }
                    }
                }
            }
            .navigationViewStyle(.stack)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let profileViewModel = ProfileViewModel(forPreviews: true)
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                ProfileView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(profileViewModel)
            }
        }
    }
}
