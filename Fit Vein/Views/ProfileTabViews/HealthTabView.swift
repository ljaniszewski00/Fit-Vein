//
//  HealthTabView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 25/10/2021.
//

import SwiftUI
import HealthKit

struct HealthTabView: View {
    @ObservedObject private var healthKitViewModel = HealthKitViewModel()
    @AppStorage("showAnimationsInHealthTabView") var showAnimationsInHealthTabView: Bool = true
    
    @State private var showingAnimations = true
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            
            NavigationView {
                VStack {
                    HStack {
                        Spacer()
                        tileView(tileNumber: 0, tileName: String(localized: "HealthTabView_steps"), tileImage: "flame.fill", tileValue: healthKitViewModel.stepCount.last == nil ? "-" : "\(healthKitViewModel.value(from: healthKitViewModel.stepCount.last!.stat).value) \(healthKitViewModel.value(from: healthKitViewModel.stepCount.last!.stat).units)")
                        Spacer()
                        tileView(tileNumber: 1, tileName: String(localized: "HealthTabView_calories"), tileImage: "flame.fill", tileValue: healthKitViewModel.activeEnergyBurned.last == nil ? "-" : "\(healthKitViewModel.value(from: healthKitViewModel.activeEnergyBurned.last!.stat).value) \(healthKitViewModel.value(from: healthKitViewModel.activeEnergyBurned.last!.stat).units)")
                        Spacer()
                    }
                    
                    if showingAnimations {
                        Spacer()
                    } else {
                        Spacer(minLength: screenHeight * 0.05)
                    }
                    
                    HStack {
                        Spacer()
                        tileView(tileNumber: 2, tileName: String(localized: "HealthTabView_distance"), tileImage: "flame.fill", tileValue: healthKitViewModel.distanceWalkingRunning.last == nil ? "-" : "\(healthKitViewModel.value(from: healthKitViewModel.distanceWalkingRunning.last!.stat).value) \(healthKitViewModel.value(from: healthKitViewModel.distanceWalkingRunning.last!.stat).units)")
                        Spacer()
                        tileView(tileNumber: 3, tileName: String(localized: "HealthTabView_workout_time"), tileImage: "timer", tileValue: healthKitViewModel.appleExerciseTime.last == nil ? "-" : "\(healthKitViewModel.value(from: healthKitViewModel.appleExerciseTime.last!.stat).value) \(healthKitViewModel.value(from: healthKitViewModel.appleExerciseTime.last!.stat).units)")
                        Spacer()
                    }
                    
                    if showingAnimations {
                        Spacer()
                    } else {
                        Spacer(minLength: screenHeight * 0.05)
                    }
                    
                    HStack {
                        Spacer()
                        tileView(tileNumber: 4, tileName: String(localized: "HealthTabView_pulse"), tileImage: "heart.fill", tileValue: healthKitViewModel.heartRate.last == nil ? "-" : "\(healthKitViewModel.value(from: healthKitViewModel.heartRate.last!.stat).value) \(healthKitViewModel.value(from: healthKitViewModel.heartRate.last!.stat).units)")
                        Spacer()
                    }
                    
                    Spacer()
                }
                .navigationTitle(String(localized: "HealthTabView_navigation_title"))
                .navigationBarHidden(false)
                .padding(.vertical, screenHeight * 0.03)
                .onAppear {
                    showingAnimations = showAnimationsInHealthTabView
                }
            }
            .navigationViewStyle(.stack)
        }
    }
    
    struct tileView: View {
        @AppStorage("showAnimationsInHealthTabView") var showAnimationsInHealthTabView: Bool = true
        
        @State private var showingAnimations = true
        
        private var tileNumber: Int
        private var tileName: String
        private var tileImage: String
        private var tileValue: String
        
        init(tileNumber: Int, tileName: String, tileImage: String, tileValue: String) {
            self.tileNumber = tileNumber
            self.tileName = tileName
            self.tileImage = tileImage
            self.tileValue = tileValue
        }
        
        var body: some View {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let screenHeight = geometry.size.height
                
                VStack {
                    HStack(alignment: .top) {
                        Image(systemName: tileImage)
                        Text(tileName)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        
                        if tileNumber == 4 && showingAnimations {
                            LottieView(name: "heartRate", loopMode: .loop, contentMode: .scaleAspectFill)
                                .frame(width: screenWidth * 0.3, height: screenHeight * 0.3)
                        }
                    }
                    .padding(tileNumber == 4 && showingAnimations ? .top : .vertical, screenHeight * 0.13)
                    
                    HStack(alignment: .center) {
                        Text(tileValue.contains("-") ? "-" : (tileValue.contains("km") ? tileValue : tileValue.removeCharactersFromString(string: tileValue, character: ".", before: false, upToCharacter: " ")))
                            .font(.title)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    if showingAnimations == true {
                        switch tileNumber {
                        case 0:
                            Spacer()
                            
                            HStack {
                                LottieView(name: "shoesWalking", loopMode: .loop, contentMode: .scaleAspectFill)
                                    .frame(width: screenWidth * 0.32, height: screenHeight * 0.32)
                                Spacer()
                            }
                        case 1:
                            Spacer()
                            
                            HStack {
                                LottieView(name: "flame", loopMode: .loop, contentMode: .scaleAspectFill)
                                    .frame(width: screenWidth * 0.25, height: screenHeight * 0.25)
                                Spacer()
                            }
                        case 2:
                            Spacer()
                            
                            HStack {
                                LottieView(name: "distance", loopMode: .loop, contentMode: .scaleAspectFill)
                                    .frame(width: screenWidth * 0.25, height: screenHeight * 0.25)
                                Spacer()
                            }
                        case 3:
                            Spacer()
                            
                            HStack {
                                LottieView(name: "time2", loopMode: .loop, contentMode: .scaleAspectFill)
                                    .frame(width: screenWidth * 0.22, height: screenHeight * 0.22)
                                Spacer()
                            }
                        default:
                            Spacer()
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .foregroundColor([0, 3, 4].contains(tileNumber) ? Color(UIColor.systemGray5) : .accentColor)
                .background {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundColor([0, 3, 4].contains(tileNumber) ? .accentColor : Color(UIColor.systemGray5))
                }
                .padding(.horizontal)
                .onAppear {
                    showingAnimations = showAnimationsInHealthTabView
                }
            }
        }
    }
}

struct HealthTabView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                HealthTabView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
