//
//  Post.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 28/10/2021.
//

import Foundation

struct Post: Codable, Identifiable {
    var id: String
    var author: Profile
    var addDate: Date
    var text: String
    var reactionsNumber: Int
    var commentsNumber: Int
    var comments: [Comment]?
    
    init(author: Profile, text: String, comments: [Comment]?) {
        self.id = UUID().uuidString
        self.author = author
        self.addDate = Date()
        self.text = text
        self.reactionsNumber = 0
        self.commentsNumber = 0
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
}

struct Comment: Codable, Identifiable {
    var id: String
    var author: Profile
    var addDate: Date
    var text: String
    
    init(author: Profile, text: String) {
        self.id = UUID().uuidString
        self.author = author
        self.addDate = Date()
        self.text = text
    }
}
