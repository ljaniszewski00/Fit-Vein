//
//  Functions.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 13/10/2021.
//

import Foundation
import SwiftUI

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

public func getTextTimeFromDuration(duration: Int) -> Text {
    var secondsRemaining = 0
    var minutesRemaining = 0
    
    if duration >= 60 {
        minutesRemaining = Int(duration / 60)
        secondsRemaining = duration - (60 * minutesRemaining)
    } else {
        minutesRemaining = 0
        secondsRemaining = duration
    }
    
    if minutesRemaining < 10 {
        if secondsRemaining < 10 {
            return Text("0\(minutesRemaining):0\(secondsRemaining)")
        } else {
            return Text("0\(minutesRemaining):\(secondsRemaining)")
        }
    } else {
        if secondsRemaining < 10 {
            return Text("\(minutesRemaining):0\(secondsRemaining)")
        } else {
            return Text("\(minutesRemaining):\(secondsRemaining)")
        }
    }
}

public func firstDayOfWeek() -> Date {
    return Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
}
