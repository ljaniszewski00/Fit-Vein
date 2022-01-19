//
//  ProfileView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
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
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
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
                                    if let profilePictureURL = profileViewModel.profilePicturePhotoURL {
                                        AsyncImage(url: profilePictureURL) { phase in
                                            if let image = phase.image {
                                                image
                                                    .resizable()
                                                    .onTapGesture {
                                                        self.shouldPresentAddActionSheet = true
                                                    }
                                            } else {
                                                Image(uiImage: UIImage(named: "blank-profile-hi")!)
                                                    .resizable()
                                                    .shadow(color: .gray, radius: 7)
                                            }
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
                                            
                                            Text("Go to 'Workout' Tab to do your first training!")
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
                    .onAppear {
                        withAnimation {
                            self.shouldShowLevelUpAnimation = self.shouldShowLevelUpAnimationTrigger
//                                if !alreadyAppearedOnce {
//                                    self.profileViewModel.fetchData()
//                                    self.alreadyAppearedOnce = true
//                                }
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
