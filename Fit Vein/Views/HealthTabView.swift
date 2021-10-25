//
//  HealthTabView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 25/10/2021.
//

import SwiftUI

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
                        ForEach(0..<dataNames.count) { number in
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .frame(height: screenHeight * 0.2)
                                    .foregroundColor([0, 3, 4].contains(number) ? .green : Color(UIColor.systemGray5))
                                
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
                                .foregroundColor([0, 3, 4, 7, 8].contains(number) ? Color(UIColor.systemGray5) : .green)
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
