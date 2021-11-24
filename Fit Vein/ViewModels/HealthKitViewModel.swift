//
//  HealthKitViewModel.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 24/11/2021.
//

import Foundation
import SwiftUI

@MainActor
class HealthKitViewModel: ObservableObject {
    private var healthKitRepository = HealthKitRepository()
    @Published var stepCount = [HealthStat]()
    @Published var activeEnergyBurned = [HealthStat]()
    @Published var distanceWalkingRunning = [HealthStat]()
    @Published var appleExerciseTime = [HealthStat]()
    @Published var heartRate = [HealthStat]()
    
    init() {
        self.healthKitRepository.requestAuthorization() { success in
            print("Auth success: \(success)")
        }
        
        self.healthKitRepository.requestHealthStats(by: "stepCount") { hStats in
            self.stepCount = hStats
        }
        
        self.healthKitRepository.requestHealthStats(by: "activeEnergyBurned") { hStats in
            self.activeEnergyBurned = hStats
        }
        
        self.healthKitRepository.requestHealthStats(by: "distanceWalkingRunning") { hStats in
            self.distanceWalkingRunning = hStats
        }
        
        self.healthKitRepository.requestHealthStats(by: "appleExerciseTime") { hStats in
            self.appleExerciseTime = hStats
        }
        
        self.healthKitRepository.requestHealthStats(by: "heartRate") { hStats in
            self.heartRate = hStats
        }
        
        print(self.stepCount)
        print(self.activeEnergyBurned)
        print(self.distanceWalkingRunning)
        print(self.appleExerciseTime)
        print(self.heartRate)
    }
}
