//
//  WorkoutTimerView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 26/10/2021.
//

import SwiftUI

struct WorkoutTimerView: View {
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @EnvironmentObject private var networkManager: NetworkManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scene
    
    @AppStorage("leftTime") var leftDate: Date = Date()
    
    @State private var secondsElapsedDuringBackground: Int = 0
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var secondsRound = 0
    @State private var minutesRound = 0
    @State private var currentRound = 0
    @State private var counting = false
    
    @State private var rest = false
    
    @State private var secondsElapsed = 0
    @State private var minutesElapsed = 0
    
    @State private var secondsRemaining = 0
    @State private var minutesRemaining = 0
    
    @State private var paused = false
    @State private var locked = false
    @State private var stopped = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if stopped {
                withAnimation(.linear) {
                    FinishedWorkoutView()
                        .environmentObject(workoutViewModel)
                        .environmentObject(networkManager)
                        .ignoresSafeArea()
                }
            } else {
                VStack {
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 15, lineCap: .round))
                                .padding(.horizontal)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(secondsRound) / CGFloat(rest ? workoutViewModel.workout!.restTime! : workoutViewModel.workout!.workTime!))
                                .stroke(rest ? Color(uiColor: UIColor(red: 246, green: 205, blue: 108)) : Color(uiColor: UIColor(red: 255, green: 104, blue: 108)), style: StrokeStyle(lineWidth: 15, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut)
                                .padding(.horizontal)
                            
                            Circle()
                                .foregroundColor(rest ? Color(uiColor: UIColor(red: 255, green: 248, blue: 182)) : Color(uiColor: UIColor(red: 255, green: 204, blue: 209)))
                                .frame(width: screenWidth * 0.755, height: screenHeight * 0.385)
                            
                            VStack {
                                Spacer()
                                
                                Group {
                                    if minutesRound < 10 {
                                        if secondsRound < 10 {
                                            Text("0\(minutesRound):0\(secondsRound)")
                                        } else {
                                            Text("0\(minutesRound):\(secondsRound)")
                                        }
                                    } else {
                                        if secondsRound < 10 {
                                            Text("\(minutesRound):0\(secondsRound)")
                                        } else {
                                            Text("\(minutesRound):\(secondsRound)")
                                        }
                                    }
                                }
                                .foregroundColor(.black)
                                .font(.system(size: screenHeight * 0.1, weight: .bold))
                                
                                Spacer()
                            }
                        }
                        .frame(width: screenWidth * 0.9, height: screenHeight * 0.4)
                        
                        Spacer()
                    }
                    .padding(.top)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 40, style: .continuous)
                            .foregroundColor(.white)
                            .frame(width: screenWidth, height: screenHeight)
                        
                        VStack {
                            HStack {
                                Spacer()
                                
                                Text(String(localized: "WorkoutTimerView_work_label"))
                                    .bold()
                                    .foregroundColor(.black)
                                    .background(RoundedRectangle(cornerRadius: 25).foregroundColor(Color(uiColor: UIColor(red: 255, green: 104, blue: 108))).frame(width: screenWidth * 0.35, height: screenHeight * 0.06).shadow(color: Color.black, radius: 7, x: -5, y: 5))
                                    .padding(.leading)
                                    .offset(y: -screenHeight * 0.07)
                                    .frame(width: screenWidth * 0.35)
                                    .isHidden(rest)
                                
                                Spacer()
                                
                                ZStack {
                                    Circle()
                                        .foregroundColor(Color(uiColor: UIColor(red: 30, green: 200, blue: 30)))
                                        .frame(width: screenWidth * 0.25, height: screenHeight * 0.125)
                                    
                                    Group {
                                        if paused {
                                            Button(action: {
                                                withAnimation {
                                                    paused = false
                                                }
                                            }, label: {
                                                Image(systemName: "play.circle.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                            })
                                        } else {
                                            Button(action: {
                                                withAnimation {
                                                    paused = true
                                                }
                                            }, label: {
                                                Image(systemName: "pause.circle.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                            })
                                        }
                                    }
                                    .disabled(locked)
                                    .foregroundColor(locked ? .gray : .white)
                                    .frame(width: screenWidth * 0.2, height: screenHeight * 0.1)
                                    
                                }
                                .offset(y: -screenHeight * 0.02)
                                .frame(height: screenHeight * 0.001)
                                
                                Spacer()
                                
                                Text(String(localized: "WorkoutTimerView_rest_label"))
                                    .bold()
                                    .foregroundColor(.black)
                                    .background(RoundedRectangle(cornerRadius: 25).foregroundColor(Color(uiColor: UIColor(red: 246, green: 205, blue: 108))).frame(width: screenWidth * 0.35, height: screenHeight * 0.06).shadow(color: Color.black, radius: 7, x: 5, y: 5))
                                    .padding(.trailing)
                                    .offset(y: -screenHeight * 0.07)
                                    .frame(width: screenWidth * 0.35)
                                    .isHidden(!rest)
                                
                                Spacer()
                            }
                            
                            HStack {
                                Spacer()
                                
                                LottieView(name: "avocadoWorkout", loopMode: .loop, contentMode: .scaleAspectFill)
                                    .frame(width: screenWidth * 0.3, height: screenHeight * 0.15)
                                
                                Spacer(minLength: screenWidth * 0.4)
                                
                                Button(action: {
                                    withAnimation {
                                        let completedDuration = minutesElapsed != 0 ? secondsElapsed * minutesElapsed : secondsElapsed
                                        self.workoutViewModel.stopWorkout(calories: Int(Double(completedDuration) * 0.35), completedDuration: completedDuration, completedSeries: currentRound)
                                        stopped = true
                                    }
                                }, label: {
                                    Image(systemName: "stop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                })
                                    .disabled(locked)
                                    .foregroundColor(locked ? .gray : Color(uiColor: UIColor(red: 255, green: 100, blue: 100)))
                                    .frame(width: screenWidth * 0.16, height: screenHeight * 0.08)
                                    .padding(.trailing, screenWidth * 0.05)
                                
                                Spacer()
                            }
                            .offset(y: -screenHeight * 0.04)
                            
                            Button(action: {
                                locked.toggle()
                            }, label: {
                                Image(systemName: locked ? "lock.circle.fill" : "lock.circle")
                                    .resizable()
                                    .scaledToFit()
                            })
                                .foregroundColor(.black)
                                .frame(width: screenWidth * 0.12, height: screenHeight * 0.06)
                                .offset(y: -screenHeight * 0.07)
                            
                            VStack {
                                Divider()
                                
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                        .resizable()
                                        .foregroundColor(Color(uiColor: UIColor(red: 255, green: 104, blue: 108)))
                                        .frame(width: screenWidth * 0.07, height: screenHeight * 0.035)
                                        .padding(.horizontal)
                                    
                                    Text("WorkoutTimerView_work_label")
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    getTimeText(time: workoutViewModel.workout!.workTime!)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(uiColor: UIColor(red: 255, green: 104, blue: 108)))
                                }
                                .padding(.horizontal)
                                .frame(height: screenHeight * 0.07)
                                .background(Color(uiColor: UIColor(red: 255, green: 204, blue: 209)), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                
                                HStack {
                                    Image(systemName: "pause.circle.fill")
                                        .resizable()
                                        .foregroundColor(Color(uiColor: UIColor(red: 246, green: 205, blue: 108)))
                                        .frame(width: screenWidth * 0.07, height: screenHeight * 0.035)
                                        .padding(.horizontal)
                                    
                                    Text("WorkoutTimerView_rest_label")
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    getTimeText(time: workoutViewModel.workout!.restTime!)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(uiColor: UIColor(red: 246, green: 205, blue: 108)))
                                }
                                .padding(.horizontal)
                                .frame(height: screenHeight * 0.07)
                                .background(Color(uiColor: UIColor(red: 255, green: 248, blue: 182)), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                        .resizable()
                                        .foregroundColor(Color(uiColor: UIColor(red: 148, green: 164, blue: 240)))
                                        .frame(width: screenWidth * 0.07, height: screenHeight * 0.035)
                                        .padding(.horizontal)
                                    
                                    Text(String(localized: "WorkoutTimerView_rounds"))
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Text("\(currentRound) / \(workoutViewModel.workout!.series!)")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(uiColor: UIColor(red: 148, green: 164, blue: 240)))
                                }
                                .padding(.horizontal)
                                .frame(height: screenHeight * 0.07)
                                .background(Color(uiColor: UIColor(red: 220, green: 220, blue: 255)), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .frame(width: screenWidth * 0.9)
                            .offset(y: -screenHeight * 0.07)
                            
                            Spacer()
                        }
                    }
                    .frame(width: screenWidth)
                    .padding(.top, screenHeight * 0.08)
                }
                .onDisappear {
                    dismiss()
                }
                .onChange(of: scene) { (newScene) in
                    if newScene == .background {
                        leftDate = Date()
                    }
                    
                    if newScene == .active {
                        secondsElapsedDuringBackground = Int(Date().timeIntervalSince(leftDate))
                        setWorkoutParametersAfterComingBackActive(secondsElapsedDuringBackground: secondsElapsedDuringBackground)
                    }
                }
                .background(RadialGradient(
                    gradient: Gradient(colors: [Color(uiColor: UIColor(red: 90, green: 230, blue: 90)), Color(uiColor: UIColor(red: 30, green: 200, blue: 30))]),
                    center: .topLeading,
                    startRadius: 100,
                    endRadius: 400))
                .onReceive(timer) { _ in
                    if minutesRemaining == 0 && secondsRemaining == 0 {
                        let completedDuration = minutesElapsed != 0 ? (secondsElapsed * minutesElapsed) : secondsElapsed
                        self.workoutViewModel.stopWorkout(calories: Int(Double(completedDuration) * 0.35), completedDuration: completedDuration, completedSeries: currentRound)
                        stopped = true
                    }
                    
                    if !paused {
                        //Setting Round Time Rules
                        if self.secondsRound == 1 || self.secondsRound == 0 {
                            if self.minutesRound == 0 {
                                if !self.rest {
                                    self.rest = true
                                    setRoundTime(workRound: false)
                                } else {
                                    self.rest = false
                                    setRoundTime(workRound: true)
                                }
                            } else {
                                self.minutesRound -= 1
                                self.secondsRound = 59
                            }
                        } else {
                            self.secondsRound -= 1
                        }
                        
                        //Setting Elapsed Time Rules
                        if self.secondsElapsed == 59 {
                            self.minutesElapsed += 1
                            self.secondsElapsed = 0
                        } else {
                            self.secondsElapsed += 1
                        }
                        
                        //Setting Remaining Time Rules
                        if self.secondsRemaining == 0 {
                            self.minutesRemaining -= 1
                            self.secondsRemaining = 59
                        } else {
                            self.secondsRemaining -= 1
                        }
                    }
                }
            }
        }
        .onAppear {
            UserDefaults.standard.set(false, forKey: "isTabBarHidden")
            if !counting {
                // Round Time
                setRoundTime(workRound: true)
                
                // Remaining
                setRemainingTime()
                
                counting = true
            }
        }
    }
    
    func setWorkoutParametersAfterComingBackActive(secondsElapsedDuringBackground: Int) {
        if !paused {
            let totalSecondsRemaining = minutesRemaining == 0 ? (secondsRemaining == 0 ? 0 : secondsRemaining) : minutesRemaining * secondsRemaining
            let totalSecondsElapsed = minutesElapsed == 0 ? (secondsElapsed == 0 ? 0 : secondsElapsed) : minutesElapsed * secondsElapsed
            
            if let workout = workoutViewModel.workout {
                if let workTime = workout.workTime, let restTime = workout.restTime, let series = workout.series {
                    var secondsElapsedDuringBackgroundTemp = secondsElapsedDuringBackground
                    var counter = 0
                    
                    if minutesRound == 0 ? secondsRound >= secondsElapsedDuringBackgroundTemp : minutesRound * secondsRound >= secondsElapsedDuringBackgroundTemp {
                        if minutesRound == 0 {
                            secondsRound -= secondsElapsedDuringBackgroundTemp
                        } else {
                            minutesRound -= secondsElapsedDuringBackgroundTemp / 60
                            secondsRound -= secondsElapsedDuringBackgroundTemp % 60
                        }
                    } else {
                        secondsElapsedDuringBackgroundTemp -= minutesRound == 0 ? secondsRound : minutesRound * secondsRound
//                        if rest {
//                            if workTime > 60 {
//                                minutesRound =
//                            } else {
//
//                            }
//                        } else {
//                            if workTime < 60 {
//
//                            } else {
//
//                            }
//                        }

                        while secondsElapsedDuringBackgroundTemp > 0 && currentRound != series {
                            counter += 1
                            print()
                            print("ROUND NUMBER: \(currentRound)")
                            print("SECONDS ELAPSED DURING BACKGROUND TEMP \(secondsElapsedDuringBackgroundTemp) AFTER ITERATION NO. \(counter)")
                            print("REST: \(rest)")
                            print()

                            if rest {
                                if workTime > 60 {
                                    let tempMinutesRound = minutesRound
                                    let tempSecondsRound = secondsRound
                                    minutesRound = (workTime / 60) - secondsElapsedDuringBackgroundTemp / 60
                                    secondsRound = (workTime % 60) - secondsElapsedDuringBackgroundTemp % 60
                                    if tempMinutesRound == 0 {
                                        
                                    } else if tempSecondsRound == 0 {
                                        
                                    } else if tempMinutesRound == 0 && tempSecondsRound == 0 {
                                        
                                    } else {
                                        secondsElapsedDuringBackgroundTemp -= tempMinutesRound * tempSecondsRound
                                    }
                                } else {
                                    let tempSecondsRound = secondsRound
                                    print("TEMP SECONDS ROUND \(tempSecondsRound)")
                                    secondsRound = workTime - secondsElapsedDuringBackgroundTemp
                                    print("SECONDS ROUND \(secondsRound)")
                                    secondsElapsedDuringBackgroundTemp -= tempSecondsRound
                                    print("SECONDS ELAPSED DURING BACKGROUND TEMP \(secondsElapsedDuringBackgroundTemp)")
                                }

                                if secondsElapsedDuringBackgroundTemp <= 0 {
                                    break
                                } else {
                                    currentRound += 1
                                }

                                rest = false
                            } else {
                                if restTime > 60 {
                                    let tempMinutesRound = minutesRound
                                    let tempSecondsRound = secondsRound
                                    minutesRound = (restTime / 60) - secondsElapsedDuringBackgroundTemp / 60
                                    secondsRound = (restTime % 60) - secondsElapsedDuringBackgroundTemp % 60
                                    secondsElapsedDuringBackgroundTemp -= tempMinutesRound * tempSecondsRound
                                } else {
                                    let tempSecondsRound = secondsRound
                                    print("TEMP SECONDS ROUND \(tempSecondsRound)")
                                    secondsRound = restTime - secondsElapsedDuringBackgroundTemp
                                    print("SECONDS ROUND \(secondsRound)")
                                    secondsElapsedDuringBackgroundTemp -= tempSecondsRound
                                    print("SECONDS ELAPSED DURING BACKGROUND TEMP \(secondsElapsedDuringBackgroundTemp)")
                                }

                                rest = true

                            }
                        }
                    }
                }
            }
            
            if totalSecondsRemaining - secondsElapsedDuringBackground <= 0 {
                minutesElapsed += totalSecondsRemaining / 60
                secondsElapsed += totalSecondsRemaining % 60
                
                print()
                print(totalSecondsRemaining)
                print(secondsElapsedDuringBackground)
                print("Here was 0 set for remaining")
                print()
                
                minutesRemaining = 0
                secondsRemaining = 0
            } else {
                minutesElapsed += secondsElapsedDuringBackground / 60
                secondsElapsed += secondsElapsedDuringBackground % 60
                
                minutesRemaining -= secondsElapsedDuringBackground / 60
                secondsRemaining -= secondsElapsedDuringBackground % 60
                
                print()
                print("MINUTES REMAINING: \(minutesRemaining)")
                print("SECONDS REMAINING: \(secondsRemaining)")
            }
        }
    }
    
    func setRoundTime(workRound: Bool) {
        if let workout = workoutViewModel.workout {
            if let workTime = workout.workTime, let restTime = workout.restTime {
                if workRound {
                    self.currentRound += 1
                    if workTime >= 60 {
                        self.minutesRound = Int(workTime / 60)
                        self.secondsRound = workTime - (60 * self.minutesRound)

                    } else {
                        self.minutesRound = 0
                        self.secondsRound = workTime
                    }
                } else {
                    if restTime >= 60 {
                        self.minutesRound = Int(restTime / 60)
                        self.secondsRound = restTime - (60 * self.minutesRound)

                    } else {
                        self.minutesRound = 0
                        self.secondsRound = restTime
                    }
                }
            }
        }
        
    }
    
    func setRemainingTime() {
        if let workout = workoutViewModel.workout {
            if let duration = workout.duration {
                if duration >= 60 {
                    self.minutesRemaining = Int(duration / 60)
                    self.secondsRemaining = duration - (60 * self.minutesRemaining)
                } else {
                    self.minutesRemaining = 0
                    self.secondsRemaining = duration
                }
            }
        }
    }
    
    func getTimeText(time: Int) -> Text {
        if let workTime = workoutViewModel.workout!.workTime {
            if time > 60 {
                if time / 60 > 9 {
                    return Text("\(time / 60):\(time % 60)")
                } else {
                    if workTime % 60 > 9 {
                        return Text("0\(time / 60):\(time % 60)")
                    } else {
                        return Text("0\(time / 60):0\(time % 60)")
                    }
                }
            } else {
                if workTime > 9 {
                    return Text("00:\(time)")
                } else {
                    return Text("00:0\(time)")
                }
            }
        } else {
           return Text("00:00")
        }
    }
}

struct WorkoutTimerView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutViewModel = WorkoutViewModel(forPreviews: true)
        let networkManager = NetworkManager()
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone 11 Pro Max", "iPhone 8"], id: \.self) { deviceName in
                WorkoutTimerView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(workoutViewModel)
                    .environmentObject(networkManager)
            }
        }
    }
}
