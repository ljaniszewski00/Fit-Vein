//
//  WorkoutTabView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 25/10/2021.
//

import SwiftUI

struct WorkoutTabView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @State private var howToDisplay = 0
    
    var body: some View {
        GeometryReader { geometry in
            
            NavigationView {
                Group {
                    if howToDisplay == 0 {
                        WorkoutTabViewWindows()
                    } else {
                        WorkoutTabViewList()
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
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    
    var body: some View {
        GeometryReader { geometry in
            
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
    @EnvironmentObject var profileViewModel: ProfileViewModel
    
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

struct WorkoutTabView_Previews: PreviewProvider {
    static var previews: some View {
        let profileViewModel = ProfileViewModel(forPreviews: true)
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                
                WorkoutTabView()
                    .environmentObject(profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                
                WorkoutTabViewWindows()
                    .environmentObject(profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                
                WorkoutTabViewList()
                    .environmentObject(profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
