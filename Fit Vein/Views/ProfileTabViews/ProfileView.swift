//
//  ProfileView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @EnvironmentObject private var sessionStore: SessionStore
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var tabBarHidden: Bool
    
    @State private var oldImage = UIImage()
    @State private var image = UIImage()
    
    @State private var shouldPresentAddActionSheet = false
    @State private var shouldPresentImagePicker = false
    @State private var shouldPresentCamera = false
    
    @State private var shouldPresentSettings = false
    
    @State private var tabSelection = 0
    
    @State private var alreadyAppearedOnce = false
    
    init(tabBarHidden: Binding<Bool>) {
        self._tabBarHidden = tabBarHidden
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if profileViewModel.profile != nil {
                withAnimation {
                    ScrollView(.vertical) {
                        HStack {
                            if profileViewModel.profilePicturePhotoURL != nil {
                                AsyncImage(url: profileViewModel.profilePicturePhotoURL!) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 50))
                                        .frame(width: screenWidth * 0.4, height: screenHeight * 0.2)
                                        .onTapGesture {
                                            self.shouldPresentAddActionSheet = true
                                        }
                                } placeholder: {
                                    Image(uiImage: UIImage(named: "blank-profile-hi")!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 50))
                                        .shadow(color: .gray, radius: 7)
                                        .frame(width: screenWidth * 0.4, height: screenHeight * 0.2)
                                }
                            } else {
                                Image(uiImage: UIImage(named: "blank-profile-hi")!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 50))
                                    .shadow(color: .gray, radius: 7)
                                    .frame(width: screenWidth * 0.4, height: screenHeight * 0.2)
                                    .onTapGesture {
                                        self.shouldPresentAddActionSheet = true
                                    }
                            }
                            
                            Spacer(minLength: screenWidth * 0.05)
                            
                            VStack {
                                HStack {
                                    Text(profileViewModel.profile!.firstName)
                                        .foregroundColor(.accentColor)
                                        .font(.system(size: screenHeight * 0.03))
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: SettingsView().environmentObject(sessionStore).environmentObject(profileViewModel), isActive: $shouldPresentSettings) {
                                        Button(action: {
                                            shouldPresentSettings = true
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
                            Text("Level 1")
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
                                            .frame(width: screenWidth * CGFloat(getWorkoutsDivider(workoutsCount: self.profileViewModel.workouts != nil ? self.profileViewModel.workouts!.count : 0)) / 10)
                                        
                                        Spacer()
                                    }
                                )
                                .foregroundColor(Color(UIColor.systemGray5))
                                .shadow(color: .gray, radius: 7)
                            
                            Text("\(self.profileViewModel.workouts != nil ? self.profileViewModel.workouts!.count : 0) / 10 Workouts")
                            
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
                                    VStack(spacing: screenHeight * 0.05) {
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
                                        
                                        Image(systemName: "arrow.down.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(.accentColor)
                                            .frame(width: screenWidth * 0.1, height: screenHeight * 0.1)
                                    }
                                    
                                } else {
                                    WorkoutTabView().environmentObject(profileViewModel)
                                        .frame(height: screenHeight)
                                }
                            }
                        }
                    }
                    .onAppear {
                        if !alreadyAppearedOnce {
                            self.profileViewModel.fetchData()
                            self.alreadyAppearedOnce = true
                        }
                    }
                    .navigationTitle("")
                    .navigationBarHidden(true)
                    .sheet(isPresented: $shouldPresentImagePicker) {
                        ImagePicker(sourceType: self.shouldPresentCamera ? .camera : .photoLibrary, selectedImage: self.$image)
                            .onDisappear {
                                if !self.image.isEqual(self.oldImage) {
                                    self.oldImage = image
                                    profileViewModel.uploadPhoto(image: image)
                                }
                            }
                    }
                    .actionSheet(isPresented: $shouldPresentAddActionSheet) {
                        ActionSheet(title: Text("Add a new photo"), message: nil, buttons: [
                            .default(Text("Take a new photo"), action: {
                                 self.shouldPresentImagePicker = true
                                 self.shouldPresentCamera = true
                             }),
                            .default(Text("Upload a new photo"), action: {
                                 self.shouldPresentImagePicker = true
                                 self.shouldPresentCamera = false
                             }),
                            ActionSheet.Button.cancel()
                        ])
                    }
                }
            } else {
                withAnimation {
                    ProfileTabFetchingView()
                        .onAppear() {
//                            self.profileViewModel.setup(sessionStore: sessionStore)
//                            self.profileViewModel.fetchData()
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
                let sessionStore = SessionStore(forPreviews: true)
                
                ProfileView(tabBarHidden: .constant(false))
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
                    .environmentObject(profileViewModel)
            }
        }
    }
}
