//
//  IntervalWorkoutTests.swift
//  Fit Vein Tests
//
//  Created by Łukasz Janiszewski on 04/01/2022.
//

import XCTest
@testable import Fit_Vein

class IntervalWorkoutTests: XCTestCase {

    var intervalWorkout: IntervalWorkout!
    let dateFormatter = DateFormatter()
    var date: Date = Date()

    override func setUp() {
        super.setUp()
        dateFormatter.dateFormat = "dd/MM/yy"
        date = dateFormatter.date(from: "01/02/2016")!
        intervalWorkout = IntervalWorkout(forPreviews: true, id: "id", usersID: "usersID", type: "type", date: date, isFinished: true, calories: 32, series: 5, workTime: 30, restTime: 15, completedDuration: 10, completedSeries: 0)
    }
    
    override func tearDown() {
        super.tearDown()
        intervalWorkout = nil
    }
    
    func testPostSecondInit() {
        XCTAssertEqual(intervalWorkout.id, "id")
        XCTAssertEqual(intervalWorkout.usersID, "usersID")
        XCTAssertEqual(intervalWorkout.type, "type")
        XCTAssertEqual(intervalWorkout.date, date)
        XCTAssertEqual(intervalWorkout.isFinished, true)
        XCTAssertEqual(intervalWorkout.calories, 32)
        XCTAssertEqual(intervalWorkout.series, 5)
        XCTAssertEqual(intervalWorkout.workTime, 30)
        XCTAssertEqual(intervalWorkout.restTime, 15)
        XCTAssertEqual(intervalWorkout.completedDuration, 10)
        XCTAssertEqual(intervalWorkout.completedSeries, 0)
    }
    
    func testSetDataOnEnd() {
        intervalWorkout.setDataOnEnd(calories: 200, completedDuration: 40, completedSeries: 2)
        XCTAssertEqual(intervalWorkout.isFinished, true)
        XCTAssertEqual(intervalWorkout.calories, 200)
        XCTAssertEqual(intervalWorkout.completedDuration, 40)
        XCTAssertEqual(intervalWorkout.completedSeries, 2)
    }
    
    func testSetUsersID() {
        intervalWorkout.setUsersID(usersID: "usersID2")
        XCTAssertEqual(intervalWorkout.usersID, "usersID2")
    }

}
