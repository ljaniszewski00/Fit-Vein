//
//  HealthTabView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 25/10/2021.
//

import SwiftUI
import HealthKit

struct HealthTabView: View {
    @ObservedObject private var healthKitViewModel: HealthKitViewModel
    
    init(healthKitViewModel: HealthKitViewModel) {
        self.healthKitViewModel = healthKitViewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
        
            NavigationView {
                VStack(spacing: screenHeight * 0.05) {
                    HStack {
                        Spacer()
                        tileView(tileNumber: 0, tileName: "Steps", tileImage: "flame.fill", tileValue: healthKitViewModel.stepCount.last!.stat, tileValueUnit: "")
                        Spacer()
                        tileView(tileNumber: 1, tileName: "Calories", tileImage: "flame.fill", tileValue: healthKitViewModel.activeEnergyBurned.last!.stat, tileValueUnit: "")
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        tileView(tileNumber: 2, tileName: "Distance", tileImage: "flame.fill", tileValue: healthKitViewModel.distanceWalkingRunning.last!.stat, tileValueUnit: "km")
                        Spacer()
                        tileView(tileNumber: 3, tileName: "Workout Time", tileImage: "timer", tileValue: healthKitViewModel.appleExerciseTime.last!.stat, tileValueUnit: "hours")
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        tileView(tileNumber: 4, tileName: "Pulse", tileImage: "heart.fill", tileValue: healthKitViewModel.heartRate.last!.stat, tileValueUnit: "")
                        Spacer()
                    }
                }
                .navigationTitle("Health Data")
                .navigationBarHidden(false)
            }
        }
    }
    
    struct tileView: View {
        private var tileNumber: Int
        private var tileName: String
        private var tileImage: String
        private var tileValue: HKQuantity?
        private var tileValueUnit: String
        
        init(tileNumber: Int, tileName: String, tileImage: String, tileValue: HKQuantity?, tileValueUnit: String) {
            self.tileNumber = tileNumber
            self.tileName = tileName
            self.tileImage = tileImage
            self.tileValue = tileValue
            self.tileValueUnit = tileValueUnit
        }
        
        var body: some View {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let screenHeight = geometry.size.height
                
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(height: screenHeight)
                        .foregroundColor([0, 3, 4].contains(tileNumber) ? .green : Color(UIColor.systemGray5))
                    
                    VStack {
                        HStack {
                            Image(systemName: tileImage)
                            Text(tileName)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        
                        Spacer()
                        
                        HStack {
                            Text("\(tileValue!)")
                                .font(.title)
                                .fontWeight(.bold)
                            Text(tileValueUnit)
                        }
                        
                        Spacer()
                    }
                    .foregroundColor([0, 3, 4].contains(tileNumber) ? Color(UIColor.systemGray5) : .green)
                    .padding()
                }
                .padding()
            }
        }
    }
}

struct HealthTabView_Previews: PreviewProvider {
    static var previews: some View {
        let healthKitViewModel = HealthKitViewModel()
        
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                HealthTabView(healthKitViewModel: healthKitViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
