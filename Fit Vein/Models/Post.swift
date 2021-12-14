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
    var reactionsNumber: Int
    var commentsNumber: Int
    var comments: [Comment]?
    
    init(authorID: String, authorFirstName: String, authorUsername: String, authorProfilePictureURL: String, text: String) {
        self.id = UUID().uuidString
        self.authorID = authorID
        self.authorFirstName = authorFirstName
        self.authorUsername = authorUsername
        self.authorProfilePictureURL = authorProfilePictureURL
        self.addDate = Date()
        self.text = text
        self.reactionsNumber = 0
        self.commentsNumber = 0
        self.comments = nil
    }
    
    init(id: String, authorID: String, authorFirstName: String, authorUsername: String, authorProfilePictureURL: String, addDate: Date, text: String, reactionsNumber: Int, commentsNumber: Int, comments: [Comment]?) {
        self.id = id
        self.authorID = authorID
        self.authorFirstName = authorFirstName
        self.authorUsername = authorUsername
        self.authorProfilePictureURL = authorProfilePictureURL
        self.addDate = addDate
        self.text = text
        self.reactionsNumber = reactionsNumber
        self.commentsNumber = commentsNumber
        self.comments = comments
    }
    
    mutating func editPost(newText: String) {
        self.text = newText
    }
    
    mutating func reactToPost() {
        self.reactionsNumber += 1
    }
    
    mutating func addComment(comment: Comment) {
        if self.comments != nil {
            self.comments!.append(comment)
        } else {
            self.comments = [Comment]()
            self.comments!.append(comment)
        }
        self.commentsNumber += 1
    }
    
    mutating func addComments(comments: [Comment]) {
        if self.comments != nil {
            self.comments!.append(contentsOf: comments)
        } else {
            self.comments = comments
        }
        self.commentsNumber = comments.count
    }
    
    mutating func deleteCommentFromPost(id: String) {
        if self.comments != nil {
            for (index, comment) in self.comments!.enumerated() {
                if comment.id == id {
                    self.comments!.remove(at: index)
                }
            }
        }
    }
}

struct Comment: Codable, Identifiable {
    var id: String
    var authorID: String
    var authorFirstName: String
    var authorUsername: String
    var authorProfilePictureURL: String
    var addDate: Date
    var text: String
    
    init(authorID: String, authorFirstName: String, authorUsername: String, authorProfilePictureURL: String, text: String) {
        self.id = UUID().uuidString
        self.authorID = authorID
        self.authorFirstName = authorFirstName
        self.authorUsername = authorUsername
        self.authorProfilePictureURL = authorProfilePictureURL
        self.addDate = Date()
        self.text = text
    }
    
    init(id: String, authorID: String, authorFirstName: String, authorUsername: String, authorProfilePictureURL: String, addDate: Date, text: String) {
        self.id = id
        self.authorID = authorID
        self.authorFirstName = authorFirstName
        self.authorUsername = authorUsername
        self.authorProfilePictureURL = authorProfilePictureURL
        self.addDate = addDate
        self.text = text
    }
}
