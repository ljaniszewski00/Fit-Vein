//
//  PostTests.swift
//  Fit Vein Tests
//
//  Created by Łukasz Janiszewski on 04/01/2022.
//

import XCTest
@testable import Fit_Vein

class PostTests: XCTestCase {
    var post: Post!
    var post2: Post!
    
    var comment: Comment!
    var comment2: Comment!

    override func setUp() {
        super.setUp()
        post = Post(authorID: "authorID", authorFirstName: "authorFirstName", authorUsername: "authorUsername", authorProfilePictureURL: "authorProfilePictureURL", text: "text")
        post2 = Post(id: "id", authorID: "authorID", authorFirstName: "authorFirstName", authorUsername: "authorUsername", authorProfilePictureURL: "authorProfilePictureURL", addDate: Date(), text: "text", reactionsUsersIDs: nil, commentedUsersIDs: nil, comments: nil)
        
        comment = Comment(authorID: "authorID", postID: "postID", authorFirstName: "authorFirstName", authorUsername: "authorUsername", authorProfilePictureURL: "authorProfilePictureURL", text: "text")
        comment2 = Comment(id: "id", authorID: "authorID", postID: "postID", authorFirstName: "authorFirstName", authorUsername: "authorUsername", authorProfilePictureURL: "authorProfilePictureURL", addDate: Date(), text: "text", reactionsUsersIDs: nil)
    }
    
    override func tearDown() {
        super.tearDown()
        post = nil
        post2 = nil
        
        comment = nil
        comment2 = nil
    }
    
    func testPostFirstInit() {
        XCTAssertEqual(post.authorID, "authorID")
        XCTAssertEqual(post.authorFirstName, "authorFirstName")
        XCTAssertEqual(post.authorUsername, "authorUsername")
        XCTAssertEqual(post.authorProfilePictureURL, "authorProfilePictureURL")
        XCTAssertEqual(post.text, "text")
    }
    
    func testPostSecondInit() {
        XCTAssertEqual(post2.id, "id")
        XCTAssertEqual(post2.authorID, "authorID")
        XCTAssertEqual(post2.authorFirstName, "authorFirstName")
        XCTAssertEqual(post2.authorUsername, "authorUsername")
        XCTAssertEqual(post2.authorProfilePictureURL, "authorProfilePictureURL")
        XCTAssertEqual(post2.text, "text")
        XCTAssertNil(post2.reactionsUsersIDs)
        XCTAssertNil(post2.commentedUsersIDs)
        XCTAssertNil(post2.comments)
    }
    
    func testCommentFirstInit() {
        XCTAssertEqual(comment.authorID, "authorID")
        XCTAssertEqual(comment.postID, "postID")
        XCTAssertEqual(comment.authorFirstName, "authorFirstName")
        XCTAssertEqual(comment.authorUsername, "authorUsername")
        XCTAssertEqual(comment.authorProfilePictureURL, "authorProfilePictureURL")
        XCTAssertEqual(comment.text, "text")
    }
    
    func testCommentSecondInit() {
        XCTAssertEqual(comment2.id, "id")
        XCTAssertEqual(comment2.authorID, "authorID")
        XCTAssertEqual(comment.postID, "postID")
        XCTAssertEqual(comment2.authorFirstName, "authorFirstName")
        XCTAssertEqual(comment2.authorUsername, "authorUsername")
        XCTAssertEqual(comment2.authorProfilePictureURL, "authorProfilePictureURL")
        XCTAssertEqual(comment2.text, "text")
        XCTAssertNil(comment2.reactionsUsersIDs)
    }
}
