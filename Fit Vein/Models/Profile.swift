//
//  Profile.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import Foundation
import SwiftUI

struct Profile: Codable, Identifiable {
    var id: String
    var firstName: String
    var username: String
    var birthDate: Date
    var age: Int
    var country: String
    var city: String
    var language: String
    var gender: String
    var email: String
    var profilePictureURL: URL?
}


