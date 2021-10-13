//
//  Errors.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 13/10/2021.
//

import Foundation

enum AuthError: String, Error {
    case authFailed = "Failed to authenticate the user"
    case signOutFailed = "Failed to sign out"
}

enum DatabaseError: String, Error {
    case createUserDataFailed = "Failed to create user data in database"
    case fetchUserDataFailed = "Failed to fetch data from database"
    case deleteUserDataFailed = "Failed to delete user data from database"
    case editUserDataFailed = "Failed to edit user data in database"
}
