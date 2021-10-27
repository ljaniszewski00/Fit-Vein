//
//  WorkoutView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject private var sessionStore: SessionStore
    @ObservedObject var workoutViewModel = WorkoutViewModel(forPreviews: false)
    @State var startWorkout = false
    @AppStorage("showSampleWorkoutsList") var showSampleWorkoutsList: Bool = true
    @AppStorage("showUsersWorkoutsList") var showUsersWorkoutsList: Bool = true
    @State var showSampleWorkoutsListState: Bool = true
    @State var showUsersWorkoutsListState: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if startWorkout {
                withAnimation {
                    WorkoutCountdownView(workoutViewModel: workoutViewModel)
                }
            } else {
                NavigationView {
                    VStack {
                        Spacer()
                        
                        VStack {
                            HStack {
                                Text("Sample Workouts")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Button(action: {
                                    showSampleWorkoutsList.toggle()
                                    showSampleWorkoutsListState.toggle()
                                }, label: {
                                    Image(systemName: showSampleWorkoutsList ? "chevron.down.circle.fill" : "chevron.forward.circle.fill")
                                        .foregroundColor(.green)
                                })
                                
                                Spacer()
                            }
                            .padding(.top)
                            .padding(.horizontal)
                            
                            List {
                                ForEach(workoutViewModel.workoutsList) { workout in
                                    HStack {
                                        Image(uiImage: UIImage(named: "sprint2")!)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: screenWidth * 0.1, height: screenHeight * 0.1)
                                            .padding(.trailing)
                                        
                                        VStack {
                                            Text(workout.type)
                                                .font(.title3)
                                                .fontWeight(.bold)
                                            
                                            Text("Work Time: \(workout.workTime!)")
                                            Text("Rest Time: \(workout.restTime!)")
                                            Text("Series: \(workout.series!)")
                                        }
                                    }
                                    .onTapGesture {
                                        withAnimation {
                                            workoutViewModel.workout = workout
                                            startWorkout = true
                                        }
                                    }
                                }
                            }
                            .isHidden(!showSampleWorkoutsListState)
                        }
                        
                        VStack {
                            HStack {
                                Text("User's Workouts")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Button(action: {
                                    showUsersWorkoutsList.toggle()
                                    showUsersWorkoutsListState.toggle()
                                }, label: {
                                    Image(systemName: showUsersWorkoutsList ? "chevron.down.circle.fill" : "chevron.forward.circle.fill")
                                        .foregroundColor(.green)
                                })
                                
                                Spacer()
                            }
                            .padding(.top)
                            .padding(.horizontal)
                            
                            List {
                                ForEach(workoutViewModel.usersWorkoutsList) { workout in
                                    HStack {
                                        Image(uiImage: UIImage(named: "sprint2")!)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: screenWidth * 0.1, height: screenHeight * 0.1)
                                            .padding(.trailing)
                                        
                                        VStack {
                                            Text(workout.type)
                                                .font(.title3)
                                                .fontWeight(.bold)
                                            
                                            Text("Work Time: \(workout.workTime!)")
                                            Text("Rest Time: \(workout.restTime!)")
                                            Text("Series: \(workout.series!)")
                                        }
                                    }
                                    .onTapGesture {
                                        withAnimation {
                                            workoutViewModel.workout = workout
                                            startWorkout = true
                                        }
                                    }
                                }
                                .onDelete { (indexSet) in
                                    workoutViewModel.deleteUserWorkout(indexSet: indexSet)
                                }
                            }
                            .isHidden(!showUsersWorkoutsListState)
                        }
                        .offset(y: showSampleWorkoutsListState ? 0 : -screenHeight * 0.35)
                        
                    }
                    
                    .navigationTitle("Workouts")
                    .navigationBarHidden(false)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: WorkoutAddView(workoutViewModel: workoutViewModel).navigationTitle("Add Workout").navigationBarHidden(false)) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: screenWidth * 0.07)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            
        }
        .onAppear {
            self.workoutViewModel.setup(sessionStore: sessionStore)
            self.showSampleWorkoutsListState = self.showSampleWorkoutsList
            self.showUsersWorkoutsListState = self.showUsersWorkoutsList
        }
    }
}


struct WorkoutAddView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var workoutType: String? = "Interval"
    @State var series: String = ""
    @State var workTime: String = ""
    @State var restTime: String = ""
    
    init(workoutViewModel: WorkoutViewModel) {
        self.workoutViewModel = workoutViewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
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
                    workoutViewModel.addUserWorkout(series: Int(self.series) ?? 8, workTime: Int(self.workTime) ?? 45, restTime: Int(self.restTime) ?? 15)
                    dismiss()
//                    if !self.series.isEmpty && !self.workTime.isEmpty && !self.restTime.isEmpty {
//
//                    }
                }, label: {
                    Text("Save Workout")
                        .foregroundColor(Color(uiColor: .systemGray5))
                        .fontWeight(.bold)
                })
                .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor(.green))
                .padding()
                
                Spacer()
            }
            .onDisappear {
                dismiss()
            }
        }
    }
}

struct WorkoutCountdownView: View {
    @State private var timeToFinish = 3
    @Environment(\.dismiss) var dismiss
    @ObservedObject var workoutViewModel: WorkoutViewModel
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(workoutViewModel: WorkoutViewModel) {
        self.workoutViewModel = workoutViewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if timeToFinish == 0 {
                withAnimation {
                    WorkoutTimerView(workoutViewModel: workoutViewModel)
                }
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
                .onDisappear {
                    dismiss()
                }
                .onReceive(timer) { _ in
                    if timeToFinish == 1 {
                        workoutViewModel.startWorkout(workout: workoutViewModel.workout!)
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
                
                WorkoutAddView(workoutViewModel: workoutViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
                
                WorkoutCountdownView(workoutViewModel: workoutViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
            }
        }
    }
}
