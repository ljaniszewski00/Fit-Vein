//
//  SignUpViewModel.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 13/10/2021.
//

import Foundation

@MainActor
class SignUpViewModel: ObservableObject {
    @Published private var sessionStore: SessionStore?
    private let firestoreManager = FirestoreManager()
    private let firebaseStorageManager = FirebaseStorageManager()
    
    func setup(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }
    
    func signUp(firstName: String, userName: String, birthDate: Date, country: String, city: String, language: String, email: String, password: String, gender: String) {
        Task {
            let userID = await self.sessionStore!.signUp(email: email, password: password)
            await firestoreManager.signUpDataCreation(id: userID, firstName: firstName, username: userName, birthDate: birthDate, country: country, city: city, language: language, email: email, gender: gender)
        }
    }
    
    func checkUsernameDuplicate(username: String) async throws -> Bool {
        try await firestoreManager.checkUsernameDuplicate(username: username)
    }
}
