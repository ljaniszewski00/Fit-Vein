//
//  Post.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 28/10/2021.
//

import Foundation

struct Post: Codable, Identifiable {
    var id: String
    var authorID: String
    var authorFirstName: String
    var authorUsername: String
    var authorProfilePictureURL: String
    var addDate: Date
    var text: String
    var reactionsUsersIDs: [String]?
    var comments: [Comment]?
    
    init(authorID: String, authorFirstName: String, authorUsername: String, authorProfilePictureURL: String, text: String) {
        self.id = UUID().uuidString
        self.authorID = authorID
        self.authorFirstName = authorFirstName
        self.authorUsername = authorUsername
        self.authorProfilePictureURL = authorProfilePictureURL
        self.addDate = Date()
        self.text = text
    }
    
    init(id: String, authorID: String, authorFirstName: String, authorUsername: String, authorProfilePictureURL: String, addDate: Date, text: String, reactionsUsersIDs: [String]?, comments: [Comment]?) {
        self.id = id
        self.authorID = authorID
        self.authorFirstName = authorFirstName
        self.authorUsername = authorUsername
        self.authorProfilePictureURL = authorProfilePictureURL
        self.addDate = addDate
        self.text = text
        self.reactionsUsersIDs = reactionsUsersIDs
        self.comments = comments
    }
}

struct Comment: Codable, Identifiable {
    var id: String
    var authorID: String
    var postID: String
    var authorFirstName: String
    var authorUsername: String
    var authorProfilePictureURL: String
    var addDate: Date
    var reactionsUsersIDs: [String]?
    var text: String
    
    init(authorID: String, postID: String, authorFirstName: String, authorUsername: String, authorProfilePictureURL: String, text: String) {
        self.id = UUID().uuidString
        self.authorID = authorID
        self.postID = postID
        self.authorFirstName = authorFirstName
        self.authorUsername = authorUsername
        self.authorProfilePictureURL = authorProfilePictureURL
        self.addDate = Date()
        self.text = text
    }
    
    init(id: String, authorID: String, postID: String, authorFirstName: String, authorUsername: String, authorProfilePictureURL: String, addDate: Date, text: String, reactionsUsersIDs: [String]?) {
        self.id = id
        self.authorID = authorID
        self.postID = postID
        self.authorFirstName = authorFirstName
        self.authorUsername = authorUsername
        self.authorProfilePictureURL = authorProfilePictureURL
        self.addDate = addDate
        self.reactionsUsersIDs = reactionsUsersIDs
        self.text = text
    }
}
