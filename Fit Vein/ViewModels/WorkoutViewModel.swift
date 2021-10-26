//
//  WorkoutViewModel.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import Foundation

@MainActor
class WorkoutViewModel: ObservableObject {
    @Published var sessionStore: SessionStore?
    @Published var workout: IntervalWorkout?
    private let firestoreManager = FirestoreManager()
    private let firebaseStorageManager = FirebaseStorageManager()
    
    init(forPreviews: Bool) {
        if forPreviews {
            self.workout = IntervalWorkout(id: UUID().uuidString, type: "Interval", date: Date(), isFinished: false, calories: 0, series: 8, workTime: 45, restTime: 15)
        }
    }
    
    func startWorkout(series: Int, workTime: Int, restTime: Int) {
        self.workout = IntervalWorkout(id: UUID().uuidString, type: "Interval", date: Date(), isFinished: false, calories: 0, series: series, workTime: workTime, restTime: restTime)
    }

    func stopWorkout(calories: Int, completedDuration: Int, completedSeries: Int) {
        self.workout?.setDataOnEnd(calories: calories, completedDuration: completedDuration, completedSeries: completedSeries)
    }
    
}


