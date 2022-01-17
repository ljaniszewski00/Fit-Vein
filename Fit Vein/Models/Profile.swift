//
//  Profile.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import Foundation

struct Profile: Codable, Identifiable {
    var id: String
    var firstName: String
    var username: String
    var birthDate: Date
    var age: Int
    var country: String
    var language: String
    var gender: String
    var email: String
    var profilePictureURL: String?
    var followedIDs: [String]?
    var reactedPostsIDs: [String]?
    var commentedPostsIDs: [String]?
    var reactedCommentsIDs: [String]?
    var completedWorkouts: Int = 0
    var level: Int = 1
}


