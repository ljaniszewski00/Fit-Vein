//
//  HealthStatTests.swift
//  Fit Vein Tests
//
//  Created by Łukasz Janiszewski on 04/01/2022.
//

import XCTest
@testable import Fit_Vein

class HealthStatTests: XCTestCase {
    
    var healthStat: HealthStat!
    let dateFormatter = DateFormatter()
    var date: Date = Date()

    override func setUp() {
        super.setUp()
        dateFormatter.dateFormat = "dd/MM/yy"
        date = dateFormatter.date(from: "01/02/2016")!
        healthStat = HealthStat(stat: nil, date: date)
    }
    
    override func tearDown() {
        super.tearDown()
        healthStat = nil
    }
    
    func testHealthStatIDInitialization() {
        XCTAssertNil(healthStat.stat)
        XCTAssertEqual(healthStat.date, date)
    }
}
