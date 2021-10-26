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


