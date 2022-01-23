//
//  SingleWorkoutWindowView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 18/01/2022.
//

import SwiftUI

struct SingleWorkoutWindowView: View {
    private var workout: IntervalWorkout
    
    private var dataImagesNames: [String] = ["timer", "flame.fill", "play.circle.fill", "pause.circle.fill", "123.rectangle.fill"]
    private var coloursForDataImages: [Color] = [Color.purple, Color.red, Color.blue, Color(uiColor: UIColor(red: 255, green: 255, blue: 51)), Color(uiColor: UIColor(red: 135, green: 42, blue: 42))]
    private var dataValuesUnits: [String] = ["", String(localized: "SingleWorkoutWindowsView_calories_unit"), String(localized: "SingleWorkoutWindowsView_work_time_unit"), String(localized: "SingleWorkoutWindowsView_rest_time_unit"), ""]
    private var dataNames: [String] = [String(localized: "SingleWorkoutWindowsView_duration"), String(localized: "SingleWorkoutWindowsView_calories"), String(localized: "SingleWorkoutWindowsView_work_time"), String(localized: "SingleWorkoutWindowsView_rest_time"), String(localized: "SingleWorkoutWindowsView_series")]
    
    @Environment(\.colorScheme) var colorScheme
    
    init(workout: IntervalWorkout) {
        self.workout = workout
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            ZStack {
                RoundedRectangle(cornerRadius: 25).foregroundColor(Color(UIColor.systemGray5))
                    .frame(height: screenHeight * 0.86)
                
                VStack {
                    VStack {
                        HStack(alignment: .center, spacing: screenWidth * 0.1) {
                            
                            Image(uiImage: UIImage(named: "sprint2")!)
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenWidth * 0.15, height: screenHeight * 0.1)
                            
                            VStack(spacing: screenHeight * 0.01) {
                                Text(String(localized: "SingleWorkoutWindowsView_interval_training_type"))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.accentColor)
                                
                                Text("\(getShortDate(longDate: workout.date))")
                                    .font(.subheadline)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                        }
                    }
                    .padding()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 25).foregroundColor(.accentColor)
                            .frame(height: screenHeight * 0.7)
                        
                        VStack(alignment: .center) {
                            Text(String(localized: "SingleWorkoutWindowsView_workout_details"))
                                .font(.title)
                                .bold()
                                .padding(.top)
                            
                            Divider()
                            
                            LazyVGrid(columns: [GridItem(.flexible()),
                                                GridItem(.flexible())], alignment: .leading, spacing: screenHeight * 0.02) {
                                
                                ForEach(0..<dataNames.count) { number in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .foregroundColor(Color(uiColor: UIColor(red: 80, green: 210, blue: 100)))
                                            .frame(width: screenWidth * 0.4)
                                            .padding()
                                            .shadow(radius: 15)
                                        
                                        HStack(alignment: .center) {
                                            Image(systemName: dataImagesNames[number])
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(coloursForDataImages[number])
                                                .frame(width: screenWidth * 0.06, height: screenHeight * 0.06)
                                            
                                            VStack {
                                                Spacer()
                                                
                                                HStack(alignment: .center) {
                                                    Text(dataNames[number])
                                                        .foregroundColor(coloursForDataImages[number])
                                                        .fontWeight(.bold)
                                                }
                                                
                                                HStack(alignment: .center) {
                                                    if number == 0 {
                                                        getTextTimeFromDuration(duration: workout.completedDuration!)
                                                            .font(.title)
                                                            .fontWeight(.bold)
                                                    } else if number == 1 {
                                                        Text("\(workout.calories!)")
                                                            .font(.title)
                                                            .fontWeight(.bold)
                                                    } else if number == 2 {
                                                        Text("\(workout.workTime!)")
                                                            .font(.title)
                                                            .fontWeight(.bold)
                                                    } else if number == 3 {
                                                        Text("\(workout.restTime!)")
                                                            .font(.title)
                                                            .fontWeight(.bold)
                                                    } else if number == 4 {
                                                        Text("\(workout.completedSeries!)")
                                                            .font(.title)
                                                            .fontWeight(.bold)
                                                    }
                                                    
                                                    Text(dataValuesUnits[number])
                                                }
                                                
                                                Spacer()
                                            }
                                        }
                                        .padding()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: screenWidth, height: screenHeight)
        }
    }
}

struct SingleWorkoutWindowView_Previews: PreviewProvider {
    static var previews: some View {
        let workout = IntervalWorkout(forPreviews: true, id: UUID().uuidString, usersID: "9999", type: "Interval", date: Date(), isFinished: true, calories: 200, series: 8, workTime: 45, restTime: 15, completedDuration: 8 * (45 + 15), completedSeries: 8)
        
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                SingleWorkoutWindowView(workout: workout)
            }
        }
    }
}
