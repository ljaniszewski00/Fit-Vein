//
//  Functions.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 13/10/2021.
//

import Foundation

public func yearsBetweenDate(startDate: Date, endDate: Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year], from: startDate, to: endDate)
    return components.year!
}

public func getWorkoutsDivider(workoutsCount: Int) -> Int {
    var workoutsCountNumber = workoutsCount
    while workoutsCountNumber > 10 {
        workoutsCountNumber = workoutsCountNumber / 10
    }
    return workoutsCountNumber % 10
}

public func getShortDate(longDate: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .short
    
    return dateFormatter.string(from: longDate)
}
