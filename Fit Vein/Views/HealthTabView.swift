//
//  HealthTabView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 25/10/2021.
//

import SwiftUI
import HealthKit

struct HealthTabView: View {
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
                        tileView(tileNumber: 0, tileName: "Steps", tileImage: "flame.fill", tileValue: profileViewModel.stepCount[1].stat, tileValueUnit: "")
                        tileView(tileNumber: 1, tileName: "Calories", tileImage: "flame.fill", tileValue: profileViewModel.stepCount[1].stat, tileValueUnit: "")
                        tileView(tileNumber: 2, tileName: "Distance", tileImage: "flame.fill", tileValue: profileViewModel.stepCount[1].stat, tileValueUnit: "km")
                        tileView(tileNumber: 3, tileName: "Workout Time", tileImage: "timer", tileValue: profileViewModel.stepCount[1].stat, tileValueUnit: "hours")
                        tileView(tileNumber: 4, tileName: "Pulse", tileImage: "heart.fill", tileValue: profileViewModel.stepCount[1].stat, tileValueUnit: "")
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
                        .frame(height: screenHeight * 0.2)
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
        let profileViewModel = ProfileViewModel(forPreviews: true)
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                
                HealthTabView(profileViewModel: profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
