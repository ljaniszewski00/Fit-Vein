//
//  WorkoutView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import SwiftUI

struct WorkoutView: View {
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            WorkoutCountdownView()
        }
    }
}

struct WorkoutCountdownView: View {
    @State private var timeToFinish = 3
    @Environment(\.dismiss) var dismiss
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if timeToFinish == 0 {
                WorkoutTimerView()
            } else {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Text("\(timeToFinish)")
                            .font(.system(size: screenHeight * 0.3, weight: .bold))
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .onReceive(timer) { _ in
                    if timeToFinish > 0 {
                        timeToFinish -= 1
                    } else {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                let sessionStore = SessionStore()
                
                WorkoutView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
                
                WorkoutCountdownView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
            }
        }
    }
}
