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
    @Published var sessionStore: SessionStore?
    private let firestoreManager = FirestoreManager()
    private let firebaseStorageManager = FirebaseStorageManager()
    
    @Published var profile: Profile?
    @Published var profilePicturePhotoURL: URL?
    
    @Published var fetchingData = true
    
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
        if sessionStore != nil {
            if sessionStore!.currentUser != nil {
                print("Fetching Data")
                fetchingData = true
                
                let (firstname, username, birthDate, age, country, city, language, gender, email, profilePictureURL) = try await self.firestoreManager.fetchDataForProfileViewModel(userID: sessionStore!.currentUser!.uid)
                
                self.profile = Profile(id: sessionStore!.currentUser!.uid, firstName: firstname, username: username, birthDate: birthDate, age: age, country: country, city: city, language: language, gender: gender, email: email, profilePictureURL: profilePictureURL)
                
                if profilePictureURL != nil {
                    self.firebaseStorageManager.getDownloadURLForImage(stringURL: profilePictureURL!, userID: sessionStore!.currentUser!.uid) { photoURL in
                         self.profilePicturePhotoURL = photoURL
                    }
                }
                
                Task {
                    fetchingData = false
                }
            }
        } else {
            fetchingData = false
        }
    }
    
    func uploadPhoto(image: UIImage) {
        if self.profile!.profilePictureURL != nil {
            Task {
                try await self.firebaseStorageManager.deleteImageFromStorage(userPhotoURL: self.profile!.profilePictureURL!, userID: self.profile!.id)
            }
        }
        
        self.firebaseStorageManager.uploadImageToStorage(image: image, userID: self.profile!.id) { photoURL in
            self.firestoreManager.addProfilePictureURLToUsersData(photoURL: photoURL) {
                Task {
                    try await self.fetchData()
                }
            }
        }
    }
    
    func emailAddressChange(oldEmailAddress: String, password: String, newEmailAddress: String, completion: @escaping (() -> ())) {
        self.sessionStore!.changeEmailAddress(oldEmailAddress: oldEmailAddress, password: password, newEmailAddress: newEmailAddress) {
            print("Successfully changed user's e-mail address")
        }
    }
    
    func passwordChange(emailAddress: String, oldPassword: String, newPassword: String, completion: @escaping (() -> ())) {
        self.sessionStore!.changePassword(emailAddress: emailAddress, oldPassword: oldPassword, newPassword: newPassword) {
            print("Successfully changed user's password")
        }
    }
    
    func deleteUserData(completion: @escaping (() -> ())) {
        if self.profile!.profilePictureURL != nil {
            self.firestoreManager.deleteUserData(userUID: sessionStore!.currentUser!.uid) {
                print("Successfully deleted user data")
                Task {
                    try await self.firebaseStorageManager.deleteImageFromStorage(userPhotoURL: self.profile!.profilePictureURL!, userID: self.sessionStore!.currentUser!.uid)
                    completion()
                }
            }
        }
    }
}
