//
//  WorkoutView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import SwiftUI

struct WorkoutView: View {
    @ObservedObject var workoutViewModel = WorkoutViewModel(forPreviews: false)
    @State var dataCorrect = false
    @State var startTraining = false
    
    @State var workoutType: String? = "Interval"
    @State var series: String = ""
    @State var workTime: String = ""
    @State var restTime: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if dataCorrect && startTraining {
                WorkoutCountdownView(workoutViewModel: workoutViewModel, series: Int(self.series) ?? 8, workTime: Int(self.workTime) ?? 45, restTime: Int(self.restTime) ?? 15)
            } else {
                VStack {
                    HStack {
                        Text("Start Workout")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding()
                    
                    Spacer()
                    
                    VStack {
                        HStack {
                            Text("Rounds Number")
                            Spacer()
                        }
                        
                        TextField("number", text: $series)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .keyboardType(.numberPad)
                    }
                    .padding()
                    
                    VStack {
                        HStack {
                            Text("Work Time")
                            Spacer()
                        }
                        
                        TextField("seconds", text: $workTime)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .keyboardType(.numberPad)
                    }
                    .padding()
                    
                    VStack {
                        HStack {
                            Text("Rest Time")
                            Spacer()
                        }
                        
                        TextField("seconds", text: $restTime)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .keyboardType(.numberPad)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        startTraining = true
                        if !self.series.isEmpty && !self.workTime.isEmpty && !self.restTime.isEmpty {
                            dataCorrect = true
                        }
                    }, label: {
                        Text("Start!")
                            .foregroundColor(Color(uiColor: .systemGray5))
                            .fontWeight(.bold)
                    })
                    .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor(.green))
                    .padding()
                    
                    Spacer()
                }
            }
        }
    }
}

struct WorkoutCountdownView: View {
    @State private var timeToFinish = 3
    @Environment(\.dismiss) var dismiss
    @ObservedObject var workoutViewModel: WorkoutViewModel
    
    private var series: Int
    private var workTime: Int
    private var restTime: Int
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(workoutViewModel: WorkoutViewModel, series: Int, workTime: Int, restTime: Int) {
        self.workoutViewModel = workoutViewModel
        self.series = series
        self.workTime = workTime
        self.restTime = restTime
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if timeToFinish == 0 {
                WorkoutTimerView(workoutViewModel: workoutViewModel)
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
                    if timeToFinish == 1 {
                        workoutViewModel.startWorkout(series: self.series, workTime: self.workTime, restTime: self.restTime)
                    }
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
        let sessionStore = SessionStore()
        let workoutViewModel = WorkoutViewModel(forPreviews: true)
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                WorkoutView(workoutViewModel: workoutViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
                
                WorkoutCountdownView(workoutViewModel: workoutViewModel, series: 8, workTime: 15, restTime: 5)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
            }
        }
    }
}
