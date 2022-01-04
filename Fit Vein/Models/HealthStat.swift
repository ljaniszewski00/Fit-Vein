//
//  HealthStat.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 24/11/2021.
//

import Foundation
import HealthKit

struct HealthStat: Identifiable {
    let id: UUID
    let stat: HKQuantity?
    let date: Date
    
    init(id: UUID = UUID(), stat: HKQuantity?, date: Date) {
        self.id = id
        self.stat = stat
        self.date = date
    }
}
