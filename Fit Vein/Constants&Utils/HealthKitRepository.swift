//
//  HealthKitRepository.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 24/11/2021.
//

import Foundation
import HealthKit

final class HealthKitRepository {
    var healthStore: HKHealthStore?
    
    public let allTypesNames = ["stepCount", "activeEnergyBurned", "distanceWalkingRunning", "appleExerciseTime", "heartRate"]
    
    let allTypes = Set([
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!
    ])
    
    var query: HKStatisticsCollectionQuery?
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }
    
    func requestAuthorization(completion: @escaping ((Bool) -> Void)) {
        guard let store = healthStore else {
            return
        }
        
        store.requestAuthorization(toShare: [], read: allTypes) { (success, error) in
            if let error = error {
                print("Error requesting authorization for HealthKit: \(error)")
            } else {
                completion(success)
            }
        }
    }
    
    func requestHealthStats(by category: String, completion: @escaping (([HealthStat]) -> Void)) {
        guard let store = healthStore, let type = HKObjectType.quantityType(forIdentifier: typeByCategory(category: category)) else {
            return
        }
        
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let endDate = Date()
        let anchorDate = firstDayOfWeek()
        let dailyComponent = DateComponents(day: 1)
        
        var healthStats = [HealthStat]()
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        query = HKStatisticsCollectionQuery(quantityType: type, quantitySamplePredicate: predicate, options: type == HKObjectType.quantityType(forIdentifier: typeByCategory(category: "heartRate")) ? .discreteAverage : .cumulativeSum, anchorDate: anchorDate, intervalComponents: dailyComponent)
        
        query?.initialResultsHandler = { (query, statistics, error) in
            if let error = error {
                print("Error in requestHealthStats functions in initialResultsHandler: \(error)")
            } else {
                statistics?.enumerateStatistics(from: startDate, to: endDate, with: { (stats, _) in
                    let stat = HealthStat(stat: stats.sumQuantity(), date: stats.startDate)
                    healthStats.append(stat)
                })
                
                completion(healthStats)
            }
        }
        
        guard let query = query else {
            return
        }
        
        store.execute(query)
    }
    
    private func typeByCategory(category: String) -> HKQuantityTypeIdentifier {
        switch category {
        case "stepCount":
            return .stepCount
        case "activeEnergyBurned":
            return .activeEnergyBurned
        case "distanceWalkingRunnning":
            return .distanceWalkingRunning
        case "appleExerciseTime":
            return .appleExerciseTime
        case "heartRate":
            return .heartRate
        default:
            return .stepCount
        }
    }
}
