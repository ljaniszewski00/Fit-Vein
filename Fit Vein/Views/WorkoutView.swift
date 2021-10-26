//
//  WorkoutView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import SwiftUI

struct WorkoutView: View {
    @State private var seconds = 0
    @State private var minutes = 0
    @State private var paused = false
    @State private var locked = false
    @State private var trainingStarted = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack() {
                HStack {
                    Spacer()
                    
                    ZStack {
                        Circle().stroke(lineWidth: screenWidth * 0.02)
                            .fill(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center))
                            .frame(width: screenWidth * 0.9)
                        
                        Group {
                            if minutes < 10 {
                                if seconds < 10 {
                                    Text("0\(minutes):0\(seconds)")
                                } else {
                                    Text("0\(minutes):\(seconds)")
                                }
                            } else {
                                if seconds < 10 {
                                    Text("\(minutes):0\(seconds)")
                                } else {
                                    Text("\(minutes):\(seconds)")
                                }
                            }
                        }
                        .foregroundColor(Color(UIColor.systemGray5))
                        .font(.system(size: screenHeight * 0.1, weight: .bold))
                        
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack {
                    Spacer()
                    
                    ProgressView("", value: 10, total: 100)
                        .frame(width: screenWidth * 0.9, height: screenHeight * 0.05)
                    
                    HStack {
                        Text("Elapsed")
                        Spacer()
                        Text("Remaining")
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Group {
                            if minutes < 10 {
                                if seconds < 10 {
                                    Text("0\(minutes):0\(seconds)")
                                } else {
                                    Text("0\(minutes):\(seconds)")
                                }
                            } else {
                                if seconds < 10 {
                                    Text("\(minutes):0\(seconds)")
                                } else {
                                    Text("\(minutes):\(seconds)")
                                }
                            }
                        }
                        .foregroundColor(Color(UIColor.systemGray5))
                        .font(.system(size: screenHeight * 0.03, weight: .bold))
                        
                        Spacer()
                        
                        Group {
                            if minutes < 10 {
                                if seconds < 10 {
                                    Text("0\(minutes):0\(seconds)")
                                } else {
                                    Text("0\(minutes):\(seconds)")
                                }
                            } else {
                                if seconds < 10 {
                                    Text("\(minutes):0\(seconds)")
                                } else {
                                    Text("\(minutes):\(seconds)")
                                }
                            }
                        }
                        .foregroundColor(Color(UIColor.systemGray5))
                        .font(.system(size: screenHeight * 0.03, weight: .bold))
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
                    .padding(.bottom, screenHeight * 0.05)
                    
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
                            .frame(width: screenWidth * (paused ? 0.16 : 0.24), height: screenHeight * (paused ? 0.08 : 0.12))
                        
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "stop.circle.fill")
                                .resizable()
                                .scaledToFit()
                        })
                            .disabled(locked)
                            .foregroundColor(locked ? Color(uiColor: .systemGray5) : .red)
                            .frame(width: screenWidth * 0.16, height: screenHeight * 0.08)
                        
                        Spacer()
                    }
                }
                .background(RoundedRectangle(cornerRadius: 25)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.clear]), startPoint: .top, endPoint: .bottom))
                                .frame(width: screenWidth, height: screenHeight * 0.4)
                                .ignoresSafeArea())
                
                Spacer(minLength: screenHeight * 0.08)
            }
            .background(RadialGradient(
                gradient: Gradient(colors: [Color.green, Color(uiColor: .systemGray5)]),
                center: .center,
                startRadius: 100,
                endRadius: 500))
            .onReceive(timer) { _ in
                if !paused {
                    if self.seconds == 59 {
                        self.minutes += 1
                        self.seconds = 0
                    } else {
                        self.seconds += 1
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
            }
        }
    }
}
