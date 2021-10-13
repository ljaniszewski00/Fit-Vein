//
//  SignInViewModel.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 13/10/2021.
//

import Foundation

class SignInViewModel: ObservableObject {
    @Published private var sessionStore: SessionStore?
    private let firestoreManager = FirestoreManager()
    private let firebaseStorageManager = FirebaseStorageManager()
    
    func setup(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }
    
    @MainActor
    func signIn(email: String, password: String) {
        Task {
            await self.sessionStore!.signIn(email: email, password: password)
        }
    }
}
