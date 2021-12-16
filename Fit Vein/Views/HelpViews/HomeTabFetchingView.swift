//
//  HomeTabFetchingView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 23/11/2021.
//

import SwiftUI

struct HomeTabFetchingView: View {
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                VStack {
                    HStack {
                        Circle()
                            .padding(.leading, screenWidth * 0.05)
                            .foregroundColor(Color(uiColor: .systemGray6))
                            .frame(width: screenWidth * 0.18, height: screenHeight * 0.08)
                        
                        VStack {
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundColor(Color(uiColor: .systemGray6))
                                .frame(width: screenWidth * 0.6, height: screenHeight * 0.03)
                            
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundColor(Color(uiColor: .systemGray6))
                                .frame(width: screenWidth * 0.6, height: screenHeight * 0.03)
                        }
                        .frame(width: screenWidth * 0.8, height: screenHeight * 0.15)
                    }
                    
                    Divider()
                    
                    HStack {
                    }
                    .frame(height: screenHeight * 0.04)
                    
                    Divider()
                    
                    Spacer(minLength: screenHeight * 0.05)
                    
                    HStack {
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundColor(Color(uiColor: .systemGray6))
                            .frame(width: screenWidth * 0.8, height: screenHeight * 0.05)
                    }
                    .padding()
                    
                    ForEach(0..<3) { _ in
                        VStack {
                            Rectangle()
                                .foregroundColor(Color(uiColor: .systemGray6))
                                .frame(width: screenWidth, height: screenHeight * 0.02)
                            
                            HStack {
                                Circle()
                                    .padding(.leading, screenWidth * 0.05)
                                    .foregroundColor(Color(uiColor: .systemGray6))
                                    .frame(width: screenWidth * 0.18, height: screenHeight * 0.08)
                                
                                VStack {
                                    HStack {
                                        RoundedRectangle(cornerRadius: 25)
                                            .foregroundColor(Color(uiColor: .systemGray6))
                                            .frame(width: screenWidth * 0.15, height: screenHeight * 0.02)
                                        RoundedRectangle(cornerRadius: 25)
                                            .foregroundColor(Color(uiColor: .systemGray6))
                                            .frame(width: screenWidth * 0.15, height: screenHeight * 0.02)
                                        Spacer()
                                    }
                                    .padding(.bottom, screenHeight * 0.001)
                                    
                                    HStack {
                                        RoundedRectangle(cornerRadius: 25)
                                            .foregroundColor(Color(uiColor: .systemGray6))
                                            .frame(width: screenWidth * 0.4, height: screenHeight * 0.02)
                                        Spacer()
                                    }
                                }
                            }
                            
                            Spacer(minLength: screenHeight * 0.04)
                            
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundColor(Color(uiColor: .systemGray6))
                                .frame(width: screenWidth * 0.7, height: screenHeight * 0.04)
                            
                            Spacer()
                            
                            HStack {
                            }
                            .frame(height: screenHeight * 0.04)
                            
                            Divider()
                            
                            HStack {
                            }
                            .frame(height: screenHeight * 0.04)
                            
                            Divider()
                        }
                    }
                }
            }
        }
    }
}

struct HomeTabPostsFetchingView: View {
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                ForEach(0..<2) { _ in
                    VStack {
                        Rectangle()
                            .foregroundColor(Color(uiColor: .systemGray6))
                            .frame(width: screenWidth, height: screenHeight * 0.02)
                        
                        HStack {
                            Circle()
                                .padding(.leading, screenWidth * 0.05)
                                .foregroundColor(Color(uiColor: .systemGray6))
                                .frame(width: screenWidth * 0.18, height: screenHeight * 0.08)
                            
                            VStack {
                                HStack {
                                    RoundedRectangle(cornerRadius: 25)
                                        .foregroundColor(Color(uiColor: .systemGray6))
                                        .frame(width: screenWidth * 0.15, height: screenHeight * 0.02)
                                    RoundedRectangle(cornerRadius: 25)
                                        .foregroundColor(Color(uiColor: .systemGray6))
                                        .frame(width: screenWidth * 0.15, height: screenHeight * 0.02)
                                    Spacer()
                                }
                                .padding(.bottom, screenHeight * 0.001)
                                
                                HStack {
                                    RoundedRectangle(cornerRadius: 25)
                                        .foregroundColor(Color(uiColor: .systemGray6))
                                        .frame(width: screenWidth * 0.4, height: screenHeight * 0.02)
                                    Spacer()
                                }
                            }
                        }
                        
                        Spacer(minLength: screenHeight * 0.04)
                        
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundColor(Color(uiColor: .systemGray6))
                            .frame(width: screenWidth * 0.7, height: screenHeight * 0.04)
                        
                        Spacer()
                        
                        HStack {
                        }
                        .frame(height: screenHeight * 0.04)
                        
                        Divider()
                        
                        HStack {
                        }
                        .frame(height: screenHeight * 0.04)
                        
                        Divider()
                    }
                }
            }
        }
    }
}

struct HomeTabFetchingView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in

                HomeTabFetchingView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                
                HomeTabPostsFetchingView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
