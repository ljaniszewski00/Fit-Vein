//
//  SignInViewModel.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 13/10/2021.
//

import Foundation

@MainActor
class SignInViewModel: ObservableObject {
    @Published private var sessionStore: SessionStore?
    private let firestoreManager = FirestoreManager()
    private let firebaseStorageManager = FirebaseStorageManager()
    
    func setup(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }
    
    func signIn(email: String, password: String) {
        self.sessionStore!.signIn(email: email, password: password) {}
    }
    
    func sendRecoveryEmail(email: String) {
        self.sessionStore!.sendRecoveryEmail(email: email) {}
    }
}
