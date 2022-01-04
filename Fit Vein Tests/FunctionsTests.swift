//
//  FunctionsTests.swift
//  Fit Vein Tests
//
//  Created by Łukasz Janiszewski on 04/01/2022.
//

import XCTest
@testable import Fit_Vein

class FunctionsTests: XCTestCase {
    
    let dateFormatter = DateFormatter()
    
    func testYearsBetweenDate() {
        dateFormatter.dateFormat = "dd/MM/yy"
        let startDate = dateFormatter.date(from: "01/02/2016")!
        let endDate = dateFormatter.date(from: "02/02/2016")!
        
        let result = yearsBetweenDate(startDate: startDate, endDate: endDate)
        XCTAssertEqual(result, 0)
    }
    
    func testGetWorkoutsDivider() {
        var workoutsCount = 11
        let result = getWorkoutsDivider(workoutsCount: workoutsCount)
        XCTAssertEqual(result, 1)
        
        workoutsCount = 1
        XCTAssertEqual(result, 1)
    }

    func testGetShortDate() {
        let stringDate = "2022-01-04 18:04:41 +0000"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        let date = dateFormatter.date(from: stringDate)!
        let result = getShortDate(longDate: date)
        XCTAssertEqual(result, "4 stycznia 2022 o 7:04 PM")
    }

}
