//
//  FinishedWorkoutView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 26/10/2021.
//

import SwiftUI

struct FinishedWorkoutView: View {
    private var workout: IntervalWorkout
    @State private var backToBeginning = false
    
    init(workout: IntervalWorkout) {
        self.workout = workout
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if backToBeginning {
                WorkoutView()
            } else {
                VStack(spacing: screenHeight * 0.05) {
                    SingleWorkoutWindowView(workout: workout)
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            backToBeginning = true
                        }, label: {
                            Text("Save")
                                .foregroundColor(Color(uiColor: .systemGray5))
                        })
                            .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.35, height: screenHeight * 0.07).foregroundColor(.green))
                            .padding()
                        
                        Spacer()
                        
                        Button(action: {
                            backToBeginning = true
                        }, label: {
                            Text("Discard")
                                .foregroundColor(Color(uiColor: .systemGray5))
                        })
                            .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.35, height: screenHeight * 0.07).foregroundColor(.red))
                            .padding()
                        
                        Spacer()
                    }
                    .padding(.bottom, screenHeight * 0.05)
                }
            }
        }
    }
}

struct FinishedWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        let workout = IntervalWorkout(id: "1", type: "Interval", date: Date(), isFinished: true, calories: 200, series: 8, workTime: 45, restTime: 15)
        
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                let sessionStore = SessionStore()
                
                FinishedWorkoutView(workout: workout)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
            }
        }
    }
}
