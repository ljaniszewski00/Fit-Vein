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
    var duration: Double
    var date: Date
    var series: Int
    var workTime: Int
    var restTime: Int
    
    init(id: String, type: String, duration: Double, date: Date, series: Int, workTime: Int, restTime: Int) {
        self.id = id
        self.type = type
        self.duration = duration
        self.date = date
        self.series = series
        self.workTime = workTime
        self.restTime = restTime
    }
}
