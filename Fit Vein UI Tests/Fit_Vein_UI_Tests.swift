//
//  Fit_Vein_UI_Tests.swift
//  Fit Vein UI Tests
//
//  Created by Łukasz Janiszewski on 04/01/2022.
//

import XCTest

class Fit_Vein_UI_Tests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testHomeViewNotificationsButton() throws {
        let homeViewNotificationsButton = app.navigationBars.buttons["Notifications"]
        let notificationsViewTexts = app.staticTexts["Hello, World!"]
        
        sleep(4)
        
        homeViewNotificationsButton.tap()
        XCTAssertTrue(notificationsViewTexts.exists)
    }
    
    func testHomeViewSearchButton() throws {
        let homeViewNotificationsButton = app.navigationBars.buttons["Search"]
        let notificationsViewTexts = app.staticTexts["Follow"]
        
        sleep(4)
                
        homeViewNotificationsButton.tap()
        XCTAssertTrue(notificationsViewTexts.exists)
    }
    
    func testHomeViewAddPostTextField() throws {
        let scrollViewsQuery = app.scrollViews
        let homeViewAddPostTextField = scrollViewsQuery.otherElements.staticTexts["What do you want to share?"]
        let addPostViewTexts = app.staticTexts["Add a post"]
        
        sleep(4)
                
        homeViewAddPostTextField.tap()
        XCTAssertTrue(addPostViewTexts.exists)
    }
    
    func testHomeViewMoreButton() throws {
        let homeViewModeButton = app.otherElements.buttons["More"]
        let homeViewSheetEditButton = app.sheets.scrollViews.otherElements.buttons["Edit"]
        
        sleep(4)
        
        homeViewModeButton.tap()
        XCTAssertTrue(homeViewSheetEditButton.exists)
    }
    
//    func testHomeViewLikeButton() throws {
//        let homeViewNotificationsButton = app.navigationBars.buttons["Search"]
//        let notificationsViewTexts = app.staticTexts["Follow"]
//
//        homeViewNotificationsButton.tap()
//        XCTAssertTrue(notificationsViewTexts.exists)
//    }
    
    func testHomeViewCommentButton() throws {
        let scrollViewsQuery = app.scrollViews
        let homeViewCommentButton = scrollViewsQuery.otherElements.containing(.staticText, identifier:"What do you want to share?").children(matching: .button).matching(identifier: "Comment").element(boundBy: 0)
        let commentsViewLikeButton = scrollViewsQuery.otherElements.containing(.image, identifier:"Like").children(matching: .button).matching(identifier: "Like").element(boundBy: 0)
        
        sleep(4)
                
        homeViewCommentButton.tap()
        XCTAssertTrue(commentsViewLikeButton.exists)
    }
    
    func testTabBarHomeTabButton() throws {
        let TabBarHomeTabButton = app.buttons["Home"]
        let homeViewTexts = app.staticTexts["Your friends activity"]
        
        sleep(4)
                
        TabBarHomeTabButton.tap()
        XCTAssertTrue(homeViewTexts.exists)
    }
    
    func testTabBarWorkoutTabButton() throws {
        let TabBarWorkoutTabButton = app.buttons["Workout"]
        let workoutViewTexts = app.staticTexts["Interval"]
        
        sleep(4)
        
        TabBarWorkoutTabButton.tap()
        XCTAssertTrue(workoutViewTexts.exists)
    }
    
    func testTabBarProfileTabButton() throws {
        let TabBarProfileTabButton = app.buttons["Profile"]
        let profileViewTexts = app.staticTexts["Level 1"]
        
        sleep(4)
                
        TabBarProfileTabButton.tap()
        XCTAssertTrue(profileViewTexts.exists)
    }
}
