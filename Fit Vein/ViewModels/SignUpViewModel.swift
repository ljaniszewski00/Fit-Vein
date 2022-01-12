//
//  SignUpViewModel.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 13/10/2021.
//

import Foundation
import UIKit
import SwiftUI

@MainActor
class SignUpViewModel: ObservableObject {
    var sessionStore = SessionStore(forPreviews: false)
    private let firestoreManager = FirestoreManager()
    private let firebaseStorageManager = FirebaseStorageManager()
    
    func signUp(firstName: String, userName: String, birthDate: Date, country: String, language: String, email: String, password: String, gender: String, completion: @escaping ((Bool) -> ())) {
        self.sessionStore.signUp(email: email, password: password) { (userID, success) in
            if success {
                if let userID = userID {
                    self.firestoreManager.signUpDataCreation(id: userID, firstName: firstName, username: userName, birthDate: birthDate, country: country, language: language, email: email, gender: gender) { profile, success in
                        completion(success)
                    }
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    func checkUsernameDuplicate(username: String) async throws -> Bool {
        try await firestoreManager.checkUsernameDuplicate(username: username)
    }
    
    func checkEmailDuplicate(email: String) async throws -> Bool {
        try await firestoreManager.checkEmailDuplicate(email: email)
    }
}
