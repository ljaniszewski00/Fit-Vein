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
    @Published var workout: IntervalWorkout = IntervalWorkout(id: "1", type: "Interval", date: Date(), isFinished: true, calories: 200, series: 8, workTime: 45, restTime: 15)
    private let firestoreManager = FirestoreManager()
    private let firebaseStorageManager = FirebaseStorageManager()
    
//    func startWorkout() -> IntervalWorkout {
//
//    }
//
//    func stopWorkout() -> IntervalWorkout {
//
//    }
    
}


