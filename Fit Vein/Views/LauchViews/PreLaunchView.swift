//
//  PreLaunchView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 03/01/2022.
//

import SwiftUI

struct PreLaunchView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.colorScheme) var colorScheme
    @State private var showContentView: Bool = false
    
    @State private var angle: Double = 360
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 1
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            Group {
                if showContentView {
                    ContentView()
                        .environmentObject(sessionStore)
                } else {
                    VStack {
                        Text("Welcome to")
                            .font(.title)
                            .padding(.bottom, screenHeight * 0.02)
                        
                        HStack(spacing: screenWidth * 0.0001) {
                            Spacer()
                            
                            Text("Fit")
                                .foregroundColor(.green)
                                .fontWeight(.bold)
                            Text("Vein")
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .font(.system(size: screenHeight * 0.1))
                        
                        HStack {
                            Spacer()
                            
                            Image(uiImage: UIImage(named: colorScheme == .dark ? "FitVeinIconDark" : "FitVeinIconLight")!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: screenWidth * 0.2, height: screenHeight * 0.2)
                                .padding(.horizontal, screenWidth * 0.05)
                                .rotation3DEffect(.degrees(angle), axis: (x: 0.0, y: 1.0, z: 0.0))
                                .opacity(opacity)
                                .scaleEffect(scale)
                            
                            Spacer()
                        }
                        .padding(.top, screenHeight * 0.15)
                    }
                    .padding()
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 1.5).delay(0.5)) {
                    angle = 0
                    scale = 2
                    opacity = 0
                }
                withAnimation(.linear.delay(2)) {
                    showContentView = true
                }
            }
            
        }
    }
}

struct PreLaunchView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                PreLaunchView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(SessionStore(forPreviews: true))
            }
        }
    }
}
