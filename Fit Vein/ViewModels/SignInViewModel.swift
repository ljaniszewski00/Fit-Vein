//
//  SignInViewModel.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 13/10/2021.
//

import Foundation

@MainActor
class SignInViewModel: ObservableObject {
    var sessionStore = SessionStore(forPreviews: false)
    private let firestoreManager = FirestoreManager()
    private let firebaseStorageManager = FirebaseStorageManager()
    
    func signIn(email: String, password: String, completion: @escaping ((Bool) -> ())) {
        self.sessionStore.signIn(email: email, password: password) { success in
            completion(success)
        }
    }
    
    func sendRecoveryEmail(email: String, completion: @escaping ((Bool) -> ())) {
        self.sessionStore.sendRecoveryEmail(email: email) { success in
            completion(success)
        }
    }
}
