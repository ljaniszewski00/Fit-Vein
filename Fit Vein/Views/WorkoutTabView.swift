//
//  WorkoutTabView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 25/10/2021.
//

import SwiftUI

struct WorkoutTabView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    @State private var howToDisplay = 0
    
    init(profileViewModel: ProfileViewModel) {
        self.profileViewModel = profileViewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            NavigationView {
                Group {
                    if howToDisplay == 0 {
                        WorkoutTabViewWindows(profileViewModel: profileViewModel)
                    } else {
                        WorkoutTabViewList(profileViewModel: profileViewModel)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Picker("", selection: $howToDisplay) {
                            Image(systemName: "squareshape.split.2x2").tag(0)
                            Image(systemName: "list.bullet").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
            }
        }
    }
}

struct WorkoutTabViewWindows: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    
    init(profileViewModel: ProfileViewModel) {
        self.profileViewModel = profileViewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            TabView {
                ForEach(profileViewModel.workouts!) { workout in
                    SingleWorkoutWindowView(workout: workout)
                }
            }
            .tabViewStyle(.page)
            .navigationTitle("Workouts")
            .navigationBarHidden(false)
        }
    }
}

struct WorkoutTabViewList: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    
    init(profileViewModel: ProfileViewModel) {
        self.profileViewModel = profileViewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            List(profileViewModel.workouts!) { workout in
                NavigationLink(destination: SingleWorkoutWindowView(workout: workout)
                                .navigationTitle("Workout")
                                .navigationBarHidden(false)) {
                    HStack {
                        Image(uiImage: UIImage(named: "sprint2")!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenWidth * 0.1, height: screenHeight * 0.1)
                            .padding(.trailing)
                        
                        VStack {
                            Text(workout.type)
                                .font(.title3)
                                .fontWeight(.bold)
                            Text(getShortDate(longDate: workout.date))
                        }
                    }
                }
            }
            .navigationTitle("Workouts")
            .navigationBarHidden(false)
        }
    }
}

struct SingleWorkoutWindowView: View {
    private var workout: IntervalWorkout
    
    private var dataImagesNames: [String] = ["timer", "flame", "play.circle", "pause.circle", "123.rectangle"]
    private var dataNames: [String] = ["Duration", "Calories", "Work Time", "Rest Time", "Series"]
    private var dataValuesUnits: [String] = ["minutes", "cal", "km", "hours", ""]
    
    @Environment(\.colorScheme) var colorScheme
    
    init(workout: IntervalWorkout) {
        self.workout = workout
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            ZStack {
                RoundedRectangle(cornerRadius: 25).foregroundColor(Color(UIColor.systemGray5))
                
                VStack {
                    VStack {
                        HStack {
                            VStack {
                                Image(uiImage: UIImage(named: "sprint2")!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: screenWidth * 0.25, height: screenHeight * 0.3)
                                    
                            }
                            
                                
                            Spacer()
                            
                            VStack {
                                Text("\(workout.type)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                
                                Text("\(getShortDate(longDate: workout.date))")
                                    .font(.caption)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                
                                Text("Workout Details")
                                    .font(.title3)
                                    .foregroundColor(.green)
                                    .padding(.top, screenHeight * 0.02)
                                    .padding(.bottom, screenHeight * 0.01)
                                
                                Image(systemName: "arrow.down.circle.fill")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
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
                                        .frame(width: screenWidth * 0.06, height: screenHeight * 0.06)
                                    
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
                                                Text("\(Int(workout.duration!))")
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                            } else if number == 1 {
                                                Text("\(workout.calories!)")
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                            } else if number == 2 {
                                                Text("\(workout.workTime!)")
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                            } else if number == 3 {
                                                Text("\(workout.restTime!)")
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                            } else if number == 4 {
                                                Text("\(workout.series!)")
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
}

struct WorkoutTabView_Previews: PreviewProvider {
    static var previews: some View {
        let profileViewModel = ProfileViewModel(forPreviews: true)
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                
                WorkoutTabView(profileViewModel: profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                
                WorkoutTabViewWindows(profileViewModel: profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                
                WorkoutTabViewList(profileViewModel: profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
