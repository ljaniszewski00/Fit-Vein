//
//  SignInViewModel.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 13/10/2021.
//

import Foundation

@MainActor
class SignInViewModel: ObservableObject {
    @Published private(set) var sessionStore: SessionStore?
    private let firestoreManager = FirestoreManager()
    private let firebaseStorageManager = FirebaseStorageManager()
    
    func setup(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }
    
    func signIn(email: String, password: String) {
        print("TUTAJ3 \(sessionStore == nil)")
        Task {
            await self.sessionStore!.signIn(email: email, password: password)
        }
    }
}
