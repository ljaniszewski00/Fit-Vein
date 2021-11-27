//
//  HealthKitViewModel.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 24/11/2021.
//

import Foundation
import SwiftUI
import HealthKit

@MainActor
class HealthKitViewModel: ObservableObject {
    private var healthKitRepository = HealthKitRepository()
    @Published var stepCount = [HealthStat]()
    @Published var activeEnergyBurned = [HealthStat]()
    @Published var distanceWalkingRunning = [HealthStat]()
    @Published var appleExerciseTime = [HealthStat]()
    @Published var heartRate = [HealthStat]()
    
    init() {
        DispatchQueue.main.async {
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
        }
    }
    
    let measurementFormatter = MeasurementFormatter()
    
    func value(from stat: HKQuantity?) -> (value: Float, units: String) {
        guard let stat = stat else {
            return (0, "")
        }
        
        measurementFormatter.unitStyle = .short
        
        if stat.is(compatibleWith: .kilocalorie()) {
            let value = stat.doubleValue(for: .kilocalorie())
            return(Float(value), stat.description.letters)
        } else if stat.is(compatibleWith: .meter()) {
            let value = stat.doubleValue(for: .mile())
            let unit = Measurement(value: value, unit: UnitLength.miles)
            return (Float(round(value * 100) / 100.0), measurementFormatter.string(from: unit).letters)
        } else if stat.is(compatibleWith: .count()) {
            let value = stat.doubleValue(for: .count())
            return (Float(value), stat.description.letters == "count" ? "" : stat.description.letters)
        } else if stat.is(compatibleWith: .minute()) {
            let value = stat.doubleValue(for: .minute())
            return (Float(value), stat.description.letters)
        } else {
            let value = stat.doubleValue(for: HKUnit(from: "count/min"))
            return (Float(value), "BPM")
        }
    }
}
