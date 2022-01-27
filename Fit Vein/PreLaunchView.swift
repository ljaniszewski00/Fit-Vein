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
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            Group {
                if showContentView {
                    ContentView()
                        .environmentObject(sessionStore)
                } else {
                    VStack(alignment: .center) {
                        Image(uiImage: UIImage(named: colorScheme == .dark ? "FitVeinIconDark" : "FitVeinIconLight")!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth * 0.2, height: screenHeight * 0.2)
                            .padding(.top, screenHeight * 0.15)
                        
                        HStack {
                            Text("Fit")
                                .foregroundColor(.accentColor)
                                .fontWeight(.bold)
                            Text("Vein")
                                .fontWeight(.bold)
                        }
                        .font(.system(size: screenHeight * 0.1))
                        
                        LottieView(name: "dumbleLoading", loopMode: .playOnce, contentMode: .scaleAspectFill)
                            .frame(width: screenWidth * 0.6, height: screenHeight * 0.3)
                            .padding(.top, screenHeight * 0.05)
                        
                        Spacer()
                    }
                    .frame(width: screenWidth)
                }
            }
            .onAppear {
                withAnimation(.linear.delay(2.5)) {
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
