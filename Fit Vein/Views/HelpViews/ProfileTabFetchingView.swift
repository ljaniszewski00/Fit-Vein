//
//  ProfileTabFetchingView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 23/11/2021.
//

import SwiftUI

struct ProfileTabFetchingView: View {
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                HStack {
                    RoundedRectangle(cornerRadius: 50)
                        .foregroundColor(Color(uiColor: .systemGray6))
                        .frame(width: screenWidth * 0.4, height: screenHeight * 0.2)
                    
                    VStack {
                        HStack {
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundColor(Color(uiColor: .systemGray6))
                                .frame(width: screenWidth * 0.4, height: screenHeight * 0.03)
                            
                            Spacer()
                        }
                        .padding(.top, screenHeight * 0.02)
                        
                        HStack {
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundColor(Color(uiColor: .systemGray6))
                                .frame(width: screenWidth * 0.4, height: screenHeight * 0.03)
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    .frame(width: screenWidth * 0.5, height: screenHeight * 0.2)
                }
                .padding()
                
                VStack(spacing: screenHeight * 0.04) {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundColor(Color(uiColor: .systemGray6))
                        .frame(width: screenWidth * 0.9, height: screenHeight * 0.03)
                    
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundColor(Color(uiColor: .systemGray6))
                        .frame(width: screenWidth * 0.35, height: screenHeight * 0.02)
                    
                    HStack {
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundColor(Color(uiColor: .systemGray6))
                            .frame(width: screenWidth * 0.3, height: screenHeight * 0.03)
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundColor(Color(uiColor: .systemGray6))
                            .frame(width: screenWidth * 0.3, height: screenHeight * 0.03)
                        
                        Spacer()
                    }
                    .padding()
                    
                    HStack {
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundColor(Color(uiColor: .systemGray6))
                            .frame(width: screenWidth * 0.5, height: screenHeight * 0.05)
                        
                        Spacer()
                    }
                    
                    LazyVGrid(columns: [GridItem(.flexible()),
                                        GridItem(.flexible())], spacing: 0) {
                        ForEach(0..<5) { _ in
                            RoundedRectangle(cornerRadius: 25)
                                .frame(height: screenHeight * 0.2)
                                .foregroundColor(Color(uiColor: .systemGray6))
                            .padding()
                        }
                    }
                }
                .padding()
            }
            
        }
    }
}

struct ProfileTabFetchingView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in

                ProfileTabFetchingView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
