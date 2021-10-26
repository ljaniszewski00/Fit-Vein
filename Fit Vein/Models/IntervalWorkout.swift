//
//  IntervalWorkout.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 25/10/2021.
//

import Foundation

struct IntervalWorkout: Codable, Identifiable {
    var id: String
    var type: String
    var date: Date
    var isFinished: Bool
    var duration: Double?
    var calories: Int?
    var series: Int?
    var workTime: Int?
    var restTime: Int?
    
    init(id: String, type: String, date: Date, isFinished: Bool = false, duration: Double?, calories: Int?, series: Int?, workTime: Int?, restTime: Int?) {
        self.id = id
        self.type = type
        self.date = date
        self.duration = duration
        self.isFinished = isFinished
        self.calories = calories
        self.series = series
        self.workTime = workTime
        self.restTime = restTime
    }
    
    mutating func setDataOnEnd(duration: Double?, calories: Int?, series: Int?, workTime: Int?, restTime: Int?) {
        self.isFinished = true
        self.duration = duration
        self.calories = calories
        self.series = series
        self.workTime = workTime
        self.restTime = restTime
    }
}
