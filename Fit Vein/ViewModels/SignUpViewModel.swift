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
    @Published private var sessionStore: SessionStore?
    private let firestoreManager = FirestoreManager()
    private let firebaseStorageManager = FirebaseStorageManager()
    
    func setup(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }
    
    func signUp(firstName: String, userName: String, birthDate: Date, country: String, language: String, email: String, password: String, gender: String) {
        self.sessionStore!.signUp(email: email, password: password) { userID in
            self.firestoreManager.signUpDataCreation(id: userID, firstName: firstName, username: userName, birthDate: birthDate, country: country, language: language, email: email, gender: gender) { profile in
                
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
