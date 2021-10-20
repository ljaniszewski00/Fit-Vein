//
//  ProfileViewModel.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published private var sessionStore: SessionStore?
    private let firestoreManager = FirestoreManager()
    private let firebaseStorageManager = FirebaseStorageManager()
    
    @Published var profile: Profile?
    
    init(forPreviews: Bool) {
        self.profile = Profile(id: "sessionStore!.currentUser!.uid", firstName: "firstname", username: "username", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", gender: "gender", email: "email", profilePictureURL: nil)
    }
    
    init() {
        Task {
            try await fetchData()
        }
    }
    
    func setup(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }
    
    func fetchData() async throws {
        print("Fetching Data")
        
        let (firstname, username, birthDate, age, country, city, language, gender, email, profilePictureURL) = try await self.firestoreManager.fetchDataForProfileViewModel(userID: sessionStore!.currentUser!.uid)
        
        self.profile = Profile(id: sessionStore!.currentUser!.uid, firstName: firstname, username: username, birthDate: birthDate, age: age, country: country, city: city, language: language, gender: gender, email: email, profilePictureURL: profilePictureURL)
    }
    
    func uploadPhoto(image: UIImage) {
        Task {
            let photoURL = try await self.firebaseStorageManager.uploadImageToStorage(image: image, userID: self.profile!.id)
            print("TUTAJ PELNA: \(photoURL!)")
            try await self.firestoreManager.addProfilePictureToUsersData(photoURL: photoURL!)
            try await self.fetchData()
        }
    }
}
