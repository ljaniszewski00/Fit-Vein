//
//  WorkoutTimerView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 26/10/2021.
//

import SwiftUI

struct WorkoutTimerView: View {
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
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
                withAnimation {
                    FinishedWorkoutView()
                        .environmentObject(workoutViewModel)
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
                                .stroke(AngularGradient(gradient: Gradient(colors: [.red, .yellow, appPrimaryColor, .blue, .purple, .red]), center: .center), style: StrokeStyle(lineWidth: 15, lineCap: .round))
                                .shadow(color: Color.black, radius: 5, x: -10, y: 10)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut)
                                .padding(.horizontal)
                            
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
                                .foregroundColor(Color(UIColor.systemGray5))
                                .font(.system(size: screenHeight * 0.1, weight: .bold))
                                .padding(.bottom, screenHeight * 0.02)
                                
                                Text(rest ? "REST" : "WORK")
                                    .font(.title)
                                    .background(RoundedRectangle(cornerRadius: 25).foregroundColor(rest ? .yellow : .red).frame(width: screenWidth * 0.3, height: screenHeight * 0.06))
                                    .shadow(color: Color.black, radius: 7, x: 10, y: 10)
                                    .padding(.bottom, screenHeight * 0.12)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    Spacer(minLength: screenHeight * 0.08)
                    
                    VStack {
                        HStack {
                            Text("Elapsed")
                            Spacer()
                            Text("Rounds").padding(.leading, screenWidth * 0.045)
                            Spacer()
                            Text("Remaining")
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Group {
                                if minutesElapsed < 10 {
                                    if secondsElapsed < 10 {
                                        Text("0\(minutesElapsed):0\(secondsElapsed)")
                                    } else {
                                        Text("0\(minutesElapsed):\(secondsElapsed)")
                                    }
                                } else {
                                    if secondsElapsed < 10 {
                                        Text("\(minutesElapsed):0\(secondsElapsed)")
                                    } else {
                                        Text("\(minutesElapsed):\(secondsElapsed)")
                                    }
                                }
                            }
                            .foregroundColor(Color(UIColor.systemGray5))
                            .font(.system(size: screenHeight * 0.03, weight: .bold, design: .monospaced))
                            
                            Spacer()
                            
                            Text("\(currentRound) / \(self.workoutViewModel.workout!.series!)")
                                .foregroundColor(Color(UIColor.systemGray5))
                                .font(.system(size: screenHeight * 0.03, weight: .bold))
                            
                            Spacer()
                            
                            Group {
                                if minutesRemaining < 10 {
                                    if secondsRemaining < 10 {
                                        Text("0\(minutesRemaining):0\(secondsRemaining)")
                                    } else {
                                        Text("0\(minutesRemaining):\(secondsRemaining)")
                                    }
                                } else {
                                    if secondsRemaining < 10 {
                                        Text("\(minutesRemaining):0\(secondsRemaining)")
                                    } else {
                                        Text("\(minutesRemaining):\(secondsRemaining)")
                                    }
                                }
                            }
                            .foregroundColor(Color(UIColor.systemGray5))
                            .font(.system(size: screenHeight * 0.03, weight: .bold, design: .monospaced))
                        }
                        .padding(.horizontal)
                        .padding(.bottom, screenHeight * 0.01)
                        
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                locked.toggle()
                            }, label: {
                                Image(systemName: locked ? "lock.circle.fill" : "lock.circle")
                                    .resizable()
                                    .scaledToFit()
                            })
                                .foregroundColor(Color(uiColor: .systemGray5))
                                .frame(width: screenWidth * 0.12, height: screenHeight * 0.06)
                            
                            Spacer()
                        }
                        .padding(.top, screenHeight * 0.025)
                        .padding(.bottom, screenHeight * 0.045)
                        
                        HStack(spacing: screenWidth * 0.1) {
                            Spacer()
                            
                            Button(action: {
                                paused = false
                            }, label: {
                                Image(systemName: "play.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                            })
                                .disabled(locked)
                                .foregroundColor(locked ? Color(uiColor: .systemGray5) : .blue)
                                .shadow(color: Color.black, radius: 5, x: 0, y: 10)
                                .frame(width: screenWidth * (!paused ? 0.16 : 0.24), height: screenHeight * (!paused ? 0.08 : 0.12))
                            
                            Button(action: {
                                paused = true
                            }, label: {
                                Image(systemName: "pause.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                            })
                                .disabled(locked)
                                .foregroundColor(locked ? Color(uiColor: .systemGray5) : .yellow)
                                .shadow(color: Color.black, radius: 5, x: 0, y: 10)
                                .frame(width: screenWidth * (paused ? 0.16 : 0.24), height: screenHeight * (paused ? 0.08 : 0.12))
                            
                            Button(action: {
                                self.workoutViewModel.stopWorkout(calories: 200, completedDuration: (minutesElapsed != 0 ? secondsElapsed * minutesElapsed : secondsElapsed), completedSeries: currentRound)
                                stopped = true
                            }, label: {
                                Image(systemName: "stop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                            })
                                .disabled(locked)
                                .foregroundColor(locked ? Color(uiColor: .systemGray5) : .red)
                                .shadow(color: Color.black, radius: 5, x: 0, y: 10)
                                .frame(width: screenWidth * 0.16, height: screenHeight * 0.08)
                            
                            Spacer()
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 25)
                                    .fill(LinearGradient(gradient: Gradient(colors: [appPrimaryColor, Color.clear]), startPoint: .top, endPoint: .bottom))
                                    .frame(width: screenWidth, height: screenHeight * 0.4)
                                    .ignoresSafeArea())
                    
                    Spacer(minLength: screenHeight * 0.08)
                }
                .onDisappear {
                    dismiss()
                }
                .background(RadialGradient(
                    gradient: Gradient(colors: [appPrimaryColor, Color.black]),
                    center: .center,
                    startRadius: 100,
                    endRadius: 500))
                .onReceive(timer) { _ in
                    if minutesRemaining == 0 && secondsRemaining == 0 {
                        self.workoutViewModel.stopWorkout(calories: 200, completedDuration: secondsElapsed * minutesElapsed, completedSeries: currentRound)
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
            if !counting {
                // Round Time
                setRoundTime(workRound: true)
                
                // Remaining
                setRemainingTime()
                
                counting = true
            }
        }
    }
    
    func setRoundTime(workRound: Bool) {
        if workRound {
            self.currentRound += 1
            if workoutViewModel.workout!.workTime! >= 60 {
                self.minutesRound = Int(workoutViewModel.workout!.workTime! / 60)
                self.secondsRound = workoutViewModel.workout!.workTime! - (60 * self.minutesRound)

            } else {
                self.minutesRound = 0
                self.secondsRound = workoutViewModel.workout!.workTime!
            }
        } else {
            if workoutViewModel.workout!.restTime! >= 60 {
                self.minutesRound = Int(workoutViewModel.workout!.restTime! / 60)
                self.secondsRound = workoutViewModel.workout!.restTime! - (60 * self.minutesRound)

            } else {
                self.minutesRound = 0
                self.secondsRound = workoutViewModel.workout!.restTime!
            }
        }
    }
    
    func setRemainingTime() {
        if workoutViewModel.workout!.duration! >= 60 {
            self.minutesRemaining = Int(workoutViewModel.workout!.duration! / 60)
            self.secondsRemaining = workoutViewModel.workout!.duration! - (60 * self.minutesRemaining)
        } else {
            self.minutesRemaining = 0
            self.secondsRemaining = workoutViewModel.workout!.duration!
        }
    }
}

struct WorkoutTimerView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                let sessionStore = SessionStore(forPreviews: true)
                let workoutViewModel = WorkoutViewModel(forPreviews: true)
                
                WorkoutTimerView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
                    .environmentObject(workoutViewModel)
            }
        }
    }
}
