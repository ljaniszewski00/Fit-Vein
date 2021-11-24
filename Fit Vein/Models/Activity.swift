//
//  Activity.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 24/11/2021.
//

import Foundation

struct Activity: Identifiable {
    var id: String
    var number: Int
    var name: String
    var image: String
    
    static func allActivities() -> [Activity] {
        return [
            Activity(id: "stepCount", number: 0, name: "Steps", image: "flame.fill"),
            Activity(id: "activeEnergyBurned", number: 1, name: "Calories", image: "flame.fill"),
            Activity(id: "distanceWalkingRunning", number: 2, name: "Distance", image: "flame.fill"),
            Activity(id: "appleExerciseTime", number: 3, name: "Workout Time", image: "timer"),
            Activity(id: "heartRate", number: 4, name: "Pulse", image: "heart.fill")
        ]
    }
}
