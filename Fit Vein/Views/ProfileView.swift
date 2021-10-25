//
//  ProfileView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    @EnvironmentObject private var sessionStore: SessionStore
    @Environment(\.colorScheme) var colorScheme
    
    @State private var image = UIImage()
    
    @State private var shouldPresentAddActionSheet = false
    @State private var shouldPresentImagePicker = false
    @State private var shouldPresentCamera = false
    
    @State private var shouldPresentSettings = false
    
    @State private var tabSelection = 0
    
    init(profileViewModel: ProfileViewModel) {
        self.profileViewModel = profileViewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
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
                                .foregroundColor(.green)
                                .font(.system(size: screenHeight * 0.03))
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            NavigationLink(destination: SettingsView(profile: profileViewModel).environmentObject(sessionStore), isActive: $shouldPresentSettings) {
                                Button(action: {
                                    shouldPresentSettings = true
                                }, label: {
                                    Image(systemName: "slider.vertical.3")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                })
                                .frame(width: screenWidth * 0.12, height: screenHeight * 0.04)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
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
                                    .foregroundColor(.green)
                                    .padding()
                                    .frame(width: screenWidth * CGFloat(getWorkoutsDivider(workoutsCount: self.profileViewModel.workouts!.count)) / 10)
                                
                                Spacer()
                            }
                        )
                        .shadow(color: .gray, radius: 7)
                    
                    Text("\(self.profileViewModel.workouts!.count) / 10 Workouts")
                    
                    Spacer(minLength: screenHeight * 0.05)
                    
                    Picker("", selection: $tabSelection) {
                        Image(systemName: "heart.fill").tag(0)
                        Image(systemName: "figure.walk").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if tabSelection == 0 {
                        HealtTabView(profileViewModel: profileViewModel)
                            .frame(height: screenHeight)
                    } else {
                        WorkoutTabView(profileViewModel: profileViewModel)
                            .frame(height: screenHeight)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $shouldPresentImagePicker) {
                ImagePicker(sourceType: self.shouldPresentCamera ? .camera : .photoLibrary, selectedImage: self.$image)
                    .onDisappear {
                        profileViewModel.uploadPhoto(image: image)
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
    }
    
    struct HealtTabView: View {
        @ObservedObject private var profileViewModel: ProfileViewModel
        
        private var dataImagesNames: [String] = ["flame.fill", "flame.fill", "flame.fill", "timer", "heart.fill"]
        private var dataNames: [String] = ["Steps", "Calories", "Distance", "Workout Time", "Pulse"]
        private var dataValues: [String] = ["3069", "234", "8.8", "1.5", "98"]
        private var dataValuesUnits: [String] = ["", "", "km", "hours", ""]
        
        init(profileViewModel: ProfileViewModel) {
            self.profileViewModel = profileViewModel
        }
        
        var body: some View {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let screenHeight = geometry.size.height
            
                NavigationView {
                    ScrollView(.vertical) {
                        LazyVGrid(columns: [GridItem(.flexible()),
                                            GridItem(.flexible())], spacing: 0) {
                            ForEach(0..<dataNames.count) { number in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 25)
                                        .frame(height: screenHeight * 0.2)
                                        .foregroundColor([0, 3, 4].contains(number) ? .green : .none)
                                    
                                    VStack {
                                        HStack {
                                            Image(systemName: dataImagesNames[number])
                                            Text(dataNames[number])
                                                .fontWeight(.bold)
                                            Spacer()
                                        }
                                        
                                        Spacer()
                                        
                                        HStack {
                                            Text(dataValues[number])
                                                .font(.title)
                                                .fontWeight(.bold)
                                            Text(dataValuesUnits[number])
                                        }
                                        
                                        Spacer()
                                    }
                                    .foregroundColor([0, 3, 4, 7, 8].contains(number) ? .none : .green)
                                    .padding()
                                }
                                .padding()
                            }
                        }
                    }
                    .navigationTitle("Health Data")
                    .navigationBarHidden(false)
                }
            }
        }
    }
    
    struct WorkoutTabView: View {
        @ObservedObject private var profileViewModel: ProfileViewModel
        @Environment(\.colorScheme) var colorScheme
        
        private var dataImagesNames: [String] = ["timer", "flame", "play.circle", "pause.circle", "123.rectangle"]
        private var dataNames: [String] = ["Duration", "Calories", "Work Time", "Rest Time", "Series"]
        private var dataValuesUnits: [String] = ["minutes", "cal", "km", "hours", ""]
        
        init(profileViewModel: ProfileViewModel) {
            self.profileViewModel = profileViewModel
        }
        
        var body: some View {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let screenHeight = geometry.size.height
                
                NavigationView {
                    TabView {
                        ForEach(profileViewModel.workouts!) { workout in
                            ZStack {
                                RoundedRectangle(cornerRadius: 25).foregroundColor(Color(uiColor: UIColor.darkGray))
                                
                                VStack {
                                    VStack {
                                        HStack {
                                            VStack {
                                                Image(uiImage: UIImage(named: "sprint")!)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: screenWidth * 0.25, height: screenHeight * 0.3)
                                                
                                                Text("Image by freepik: www.freepik.com")
                                                    .font(.caption2)
                                                    .padding(.top, -screenHeight * 0.09)
                                                    .foregroundColor(Color(uiColor: UIColor.lightGray))
                                            }
                                            
                                                
                                            Spacer()
                                            
                                            VStack {
                                                Text("\(workout.type)")
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.green)
                                                
                                                Text("\(getShortDate(longDate: workout.date))")
                                                    .font(.caption)
                                                    .foregroundColor(Color(uiColor: UIColor.lightGray))
                                                
                                                Text("Workout Details")
                                                    .font(.title3)
                                                    .foregroundColor(.green)
                                                    .padding(.top, screenHeight * 0.02)
                                                    .padding(.bottom, screenHeight * 0.01)
                                                
                                                Image(systemName: "arrow.down.circle.fill")
                                                    .foregroundColor(.white)
                                                    .font(.title2)
                                            }
                                            
                                            Spacer()
                                        }
                                    }
                                    .padding()
                                    
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 25).foregroundColor(.green)
                                        
                                        LazyVGrid(columns: [GridItem(.flexible()),
                                                            GridItem(.flexible())], spacing: 0) {
                                            
                                            ForEach(0..<dataNames.count) { number in
                                                HStack {
                                                    Image(systemName: dataImagesNames[number])
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: screenWidth * 0.1, height: screenHeight * 0.1)
                                                    
                                                    Spacer()
                                                    
                                                    VStack {
                                                        Spacer()
                                                        
                                                        HStack {
                                                            Text(dataNames[number])
                                                                .fontWeight(.bold)
                                                            
                                                            Spacer()
                                                        }
                                                        
                                                        HStack {
                                                            if number == 0 {
                                                                Text("\(Int(workout.duration))")
                                                                    .font(.title)
                                                                    .fontWeight(.bold)
                                                            } else if number == 1 {
                                                                Text("\(workout.calories)")
                                                                    .font(.title)
                                                                    .fontWeight(.bold)
                                                            } else if number == 2 {
                                                                Text("\(workout.workTime)")
                                                                    .font(.title)
                                                                    .fontWeight(.bold)
                                                            } else if number == 3 {
                                                                Text("\(workout.restTime)")
                                                                    .font(.title)
                                                                    .fontWeight(.bold)
                                                            } else if number == 4 {
                                                                Text("\(workout.series)")
                                                                    .font(.title)
                                                                    .fontWeight(.bold)
                                                            }
                                                            
                                                            Text(dataValuesUnits[number])
                                                            
                                                            Spacer()
                                                        }
                                                        
                                                        Spacer()
                                                    }
                                                }
                                                .padding()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .tabViewStyle(.page)
                    .navigationTitle("Workouts")
                    .navigationBarHidden(false)
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
                let sessionStore = SessionStore()
                
                ProfileView(profileViewModel: profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
            }
        }
    }
}
