//
//  WorkoutView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject private var sessionStore: SessionStore
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @State var startWorkout = false
    @AppStorage("showSampleWorkoutsList") var showSampleWorkoutsList: Bool = true
    @AppStorage("showUsersWorkoutsList") var showUsersWorkoutsList: Bool = true
    @AppStorage("showSampleWorkoutsListFromSettings") var showSampleWorkoutsListFromSettings: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if startWorkout {
                withAnimation {
                    WorkoutCountdownView()
                        .environmentObject(workoutViewModel)
                }
            } else {
                NavigationView {
                    VStack {
                        Spacer(minLength: screenHeight * 0.05)
                        
                        List {
                            if showSampleWorkoutsListFromSettings {
                                DisclosureGroup(isExpanded: $showSampleWorkoutsList, content: {
                                    ForEach(workoutViewModel.workoutsList) { workout in
                                        HStack {
                                            Image(uiImage: UIImage(named: "sprint2")!)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: screenWidth * 0.1, height: screenHeight * 0.1)
                                            
                                            Spacer()
                                            
                                            VStack {
                                                Text(workout.type)
                                                    .foregroundColor(appPrimaryColor)
                                                    .font(.title3)
                                                    .fontWeight(.bold)
                                            }
                                            
                                            Spacer()
                                            
                                            Divider()
                                            
                                            Spacer()
                                            
                                            VStack {
                                                Text("Work Time: \(workout.workTime!)")
                                                Text("Rest Time: \(workout.restTime!)")
                                                Text("Series: \(workout.series!)")
                                            }
                                            
                                            Spacer()
                                        }
                                        .onTapGesture {
                                            withAnimation {
                                                workoutViewModel.workout = workout
                                                startWorkout = true
                                            }
                                        }
                                    }
                                }, label: {
                                    Text("Sample Workouts")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                })
                            }
                            
                            DisclosureGroup(isExpanded: $showUsersWorkoutsList, content: {
                                ForEach(workoutViewModel.usersWorkoutsList) { workout in
                                    HStack {
                                        Image(uiImage: UIImage(named: "sprint2")!)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: screenWidth * 0.1, height: screenHeight * 0.1)
                                        
                                        Spacer()
                                        
                                        VStack {
                                            Text(workout.type)
                                                .foregroundColor(appPrimaryColor)
                                                .font(.title3)
                                                .fontWeight(.bold)
                                        }
                                        
                                        Spacer()
                                        
                                        Divider()
                                        
                                        Spacer()
                                        
                                        VStack {
                                            Text("Work Time: \(workout.workTime!)")
                                            Text("Rest Time: \(workout.restTime!)")
                                            Text("Series: \(workout.series!)")
                                        }
                                        
                                        Spacer()
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
                            }, label: {
                                Text("User's Workouts")
                                    .font(.title3)
                                    .fontWeight(.bold)
                            })
                        }
                    }
                    .navigationTitle("Workouts")
                    .navigationBarHidden(false)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: WorkoutAddView().environmentObject(workoutViewModel).navigationTitle("Add Workout").navigationBarHidden(false)) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: screenWidth * 0.07)
                                    .foregroundColor(appPrimaryColor)
                            }
                        }
                    }
                }
            }
            
        }
        .onAppear {
            self.workoutViewModel.setup(sessionStore: sessionStore)
        }
    }
}


struct WorkoutAddView: View {
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var workoutType: String? = "Interval"
    @State var series: String = ""
    @State var workTime: String = ""
    @State var restTime: String = ""
    
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
                    
                    VStack {
                        TextField("number", text: $series)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .keyboardType(.numberPad)
                        Divider()
                            .background(appPrimaryColor)
                    }
                }
                .padding()
                
                VStack {
                    HStack {
                        Text("Work Time")
                        Spacer()
                    }
                    
                    VStack {
                        TextField("seconds", text: $workTime)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .keyboardType(.numberPad)
                        Divider()
                            .background(appPrimaryColor)
                    }
                }
                .padding()
                
                VStack {
                    HStack {
                        Text("Rest Time")
                        Spacer()
                    }
                    
                    VStack {
                        TextField("seconds", text: $restTime)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .keyboardType(.numberPad)
                        Divider()
                            .background(appPrimaryColor)
                    }
                    
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    workoutViewModel.addUserWorkout(series: Int(self.series) ?? 8, workTime: Int(self.workTime) ?? 45, restTime: Int(self.restTime) ?? 15)
                    dismiss()
                }, label: {
                    Text("Save Workout")
                        .foregroundColor(Color(uiColor: .systemGray5))
                        .fontWeight(.bold)
                })
                .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor(appPrimaryColor))
                .padding()
            }
            .padding(.top, screenHeight * 0.10)
            .padding(.bottom, screenHeight * 0.15)
            .onDisappear {
                dismiss()
            }
        }
    }
}

struct WorkoutCountdownView: View {
    @State private var timeToFinish = 5
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            
            if timeToFinish == 0 {
                withAnimation {
                    WorkoutTimerView()
                        .environmentObject(workoutViewModel)
                }
            } else {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 15, lineCap: .round))
                                .padding()
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(timeToFinish) / 5)
                                .stroke(appPrimaryColor, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut)
                                .padding()
                            
                            Text("\(timeToFinish)")
                                .foregroundColor(appPrimaryColor)
                                .font(.system(size: screenHeight * 0.3, weight: .bold))
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .onReceive(timer) { _ in
                    if timeToFinish == 1 {
                        if workoutViewModel.workout != nil {
                            workoutViewModel.startWorkout(workout: workoutViewModel.workout!)
                        }
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
        let sessionStore = SessionStore(forPreviews: true)
        let workoutViewModel = WorkoutViewModel(forPreviews: true)
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                WorkoutView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
                    .environmentObject(workoutViewModel)
                
                WorkoutAddView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(workoutViewModel)
                
                WorkoutCountdownView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(workoutViewModel)
            }
        }
    }
}
