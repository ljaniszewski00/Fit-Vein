//
//  FinishedWorkoutView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 26/10/2021.
//

import SwiftUI

struct FinishedWorkoutView: View {
    @EnvironmentObject private var workoutViewModel: WorkoutViewModel
    @EnvironmentObject private var networkManager: NetworkManager
    @Environment(\.dismiss) var dismiss
    @State private var backToBeginning = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if backToBeginning || workoutViewModel.workout == nil {
                withAnimation(.linear) {
                    WorkoutView()
                        .environmentObject(workoutViewModel)
                        .environmentObject(networkManager)
                }
            } else {
                VStack(spacing: screenHeight * 0.05) {
                    SingleWorkoutWindowView(workout: workoutViewModel.workout!)
                        .frame(height: screenHeight * 0.75)
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            self.workoutViewModel.saveWorkoutToDatabase() {
                                withAnimation(.linear) {
                                    backToBeginning = true
                                }
                            }
                        }, label: {
                            Text("Save")
                                .fontWeight(.bold)
                                .foregroundColor(Color(uiColor: .systemGray5))
                        })
                            .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.35, height: screenHeight * 0.07).foregroundColor(.accentColor))
                            .padding()
                            .disabled(!networkManager.isConnected)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.linear) {
                                backToBeginning = true
                            }
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
                .onDisappear {
                    dismiss()
                }
            }
        }
    }
}

struct FinishedWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        let sessionStore = SessionStore(forPreviews: true)
        let workoutViewModel = WorkoutViewModel(forPreviews: true)
        let networkManager = NetworkManager()
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                FinishedWorkoutView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
                    .environmentObject(workoutViewModel)
                    .environmentObject(networkManager)
            }
        }
    }
}
