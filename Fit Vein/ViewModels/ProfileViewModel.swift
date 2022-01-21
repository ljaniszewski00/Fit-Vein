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
    var sessionStore = SessionStore(forPreviews: false)
    private let firestoreManager = FirestoreManager()
    private let firebaseStorageManager = FirebaseStorageManager()
    
    @Published var profile: Profile?
    @Published var profilePicturePhotoURL: URL?
    @Published var profilePicturePhoto: UIImage?
    
    @Published var workouts: [IntervalWorkout]?
    
    var medals: [String: String] = ["medal": "Achieved for account registration", "medal-2": "Achieved for getting level 2", "medal-3": "Achieved for getting level 3", "medal-4": "Achieved for getting level 4"]
    
    init(forPreviews: Bool) {
        self.workouts = [IntervalWorkout(forPreviews: true, id: UUID().uuidString, usersID: "9999", type: "Interval", date: Date(), isFinished: true, calories: 200, series: 8, workTime: 45, restTime: 15, completedDuration: 8 * (45 + 15), completedSeries: 8),
                         IntervalWorkout(forPreviews: true, id: UUID().uuidString, usersID: "9999", type: "Interval", date: Date(), isFinished: true, calories: 260, series: 10, workTime: 45, restTime: 15, completedDuration: 8 * (45 + 15), completedSeries: 8),
                         IntervalWorkout(forPreviews: true, id: UUID().uuidString, usersID: "9999", type: "Interval", date: Date(), isFinished: true, calories: 140, series: 6, workTime: 45, restTime: 15, completedDuration: 8 * (45 + 15), completedSeries: 8),
                         IntervalWorkout(forPreviews: true, id: UUID().uuidString, usersID: "9999", type: "Interval", date: Date(), isFinished: true, calories: 110, series: 5, workTime: 45, restTime: 15, completedDuration: 8 * (45 + 15), completedSeries: 8),
                         IntervalWorkout(forPreviews: true, id: UUID().uuidString, usersID: "9999", type: "Interval", date: Date(), isFinished: true, calories: 260, series: 10, workTime: 45, restTime: 15, completedDuration: 8 * (45 + 15), completedSeries: 8)]
        
        self.profile = Profile(id: "sessionStore!.currentUser!.uid", firstName: "firstname", username: "username", birthDate: Date(), age: 18, country: "country", language: "language", gender: "gender", email: "email", profilePictureURL: nil, followedIDs: ["id1"])
    }
    
    init() {
        fetchData()
    }
    
    func setup(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }
    
    func fetchData() {
        if sessionStore.currentUser != nil {
            self.firestoreManager.fetchDataForProfileViewModel(userID: self.sessionStore.currentUser!.uid) { [self] fetchedProfile in
                self.profile = fetchedProfile
                
                if let profile = profile {
                    if let profilePictureURL = profile.profilePictureURL {
//                        self.firebaseStorageManager.getDownloadURLForImage(stringURL: profile!.profilePictureURL!, userID: self.sessionStore.currentUser!.uid) { photoURL, success in
//                            if let photoURL = photoURL {
//                                self.profilePicturePhotoURL = photoURL
//                            }
//                        }
                        
                        self.downloadPhoto(photoURL: profilePictureURL) { success in }
                    }
                    self.firestoreManager.fetchWorkouts(userID: profile.id) { fetchedWorkouts, success in
                        if success {
                            self.workouts = fetchedWorkouts
                        }
                    }
                }
            }
        }
    }
    
    func uploadPhoto(image: UIImage, completion: @escaping ((Bool) -> ())) {
        if let profile = self.profile {
            if let profilePictureURL = profile.profilePictureURL {
                self.firebaseStorageManager.deleteImageFromStorage(userPhotoURL: profilePictureURL, userID: profile.id) { success in }
            }
            
            self.firebaseStorageManager.uploadImageToStorage(image: image, userID: profile.id) { photoURL, success in
                if success {
                    if let photoURL = photoURL {
                        self.firestoreManager.addProfilePictureURLToUsersData(photoURL: photoURL) { success in
                            if success {
                                self.firestoreManager.postChangeAuthorProfilePictureURL(authorID: profile.id, authorProfilePictureURL: photoURL) { success in
                                    if success {
                                        self.firestoreManager.commentChangeAuthorProfilePictureURL(authorID: profile.id, authorProfilePictureURL: photoURL) { success in
                                            self.downloadPhoto(photoURL: photoURL) { success in
                                                completion(success)
                                            }
                                        }
                                    } else {
                                        completion(false)
                                    }
                                }
                            } else {
                                print("Error uploading photo for user ID: \(self.sessionStore.currentUser!.uid)")
                                completion(false)
                            }
                        }
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func downloadPhoto(photoURL: String, completion: @escaping ((Bool) -> ())) {
        if let profile = self.profile {
            if let profilePictureURL = profile.profilePictureURL {
                self.firebaseStorageManager.downloadImageFromStorage(userID: profile.id, userPhotoURL: profilePictureURL) { photo, success in
                    if let photo = photo {
                        self.profilePicturePhoto = photo
                    }
                    completion(success)
                }
            }
        }
    }
    
    func emailAddressChange(oldEmailAddress: String, password: String, newEmailAddress: String, completion: @escaping ((Bool) -> ())) {
        if self.profile != nil {
            self.sessionStore.changeEmailAddress(userID: self.profile!.id, oldEmailAddress: oldEmailAddress, password: password, newEmailAddress: newEmailAddress) { success in
                if success {
                    print("Successfully changed user's e-mail address in authentication panel")
                    self.firestoreManager.editUserEmailInDatabase(userID: self.profile!.id, email: newEmailAddress) { sucess in
                        if success {
                            print("Successfully changed user's e-mail address in firestore database")
                        } else {
                            print("Error changing user's e-mail address in firestore database")
                        }
                        completion(success)
                    }
                } else {
                    print("Error changing user's e-mail address in authentication panel")
                    completion(false)
                }
            }
        }
    }
    
    func passwordChange(emailAddress: String, oldPassword: String, newPassword: String, completion: @escaping ((Bool) -> ())) {
        self.sessionStore.changePassword(emailAddress: emailAddress, oldPassword: oldPassword, newPassword: newPassword) { success in
            if success {
                print("Successfully changed user's password")
            } else {
                print("Error changing user's password")
            }
            completion(success)
        }
    }
    
    func signOut() -> Bool {
        self.sessionStore.signOut()
    }
    
    func deleteUserData(email: String, password: String, completion: @escaping ((Bool) -> ())) {
        if self.profile != nil {
            if self.profile!.profilePictureURL != nil {
                self.firebaseStorageManager.deleteImageFromStorage(userPhotoURL: self.profile!.profilePictureURL!, userID: self.profile!.id) { success in
                    if success {
                        print("Successfully deleted user's images")
                    } else {
                        print("Could not delete user's images")
                        completion(false)
                    }
                    self.firestoreManager.deleteUserData(userID: self.profile!.id) { success in
                        if success {
                            print("Successfully deleted user's data")
                        } else {
                            print("Could not delete user's data")
                            completion(false)
                        }
                        self.sessionStore.deleteUser(email: email, password: password) { success in
                            if success {
                                print("Successfully deleted user's credentials")
                            } else {
                                print("Could not delete user's credentials")
                            }
                            completion(success)
                        }
                    }
                }
            } else {
                self.firestoreManager.deleteUserData(userID: self.profile!.id) { success in
                    if success {
                        print("Successfully deleted user's data")
                    } else {
                        print("Could not delete user's data")
                        completion(success)
                    }
                    self.sessionStore.deleteUser(email: email, password: password) { success in
                        if success {
                            print("Successfully deleted user's credentials")
                        } else {
                            print("Could not delete user's credentials")
                        }
                        completion(success)
                    }
                }
            }
        } else {
            completion(false)
        }
    }
    
    func followUser(userID: String, completion: @escaping ((Bool) -> ())) {
        if sessionStore.currentUser != nil {
            self.firestoreManager.addUserToFollowed(userID: self.sessionStore.currentUser!.uid, userIDToFollow: userID) { success in
                if success {
                }
                completion(success)
            }
        }
    }
    
    func unfollowUser(userID: String, completion: @escaping ((Bool) -> ())) {
        if sessionStore.currentUser != nil {
            self.firestoreManager.removeUserFromFollowed(userID: self.sessionStore.currentUser!.uid, userIDToStopFollow: userID) { success in
                if success {
                }
                completion(success)
            }
        }
    }
    
    func calculateUserCompletedWorkoutsForCurrentLevel() -> Int {
        if let profile = self.profile {
            switch profile.level {
            case 1...4:
                return profile.completedWorkouts % 5
            case 5...10:
                return profile.completedWorkouts % 10
            default:
                return 0
            }
        } else {
            return 0
        }
    }
    
    func calculateUserMaxWorkoutsForLevel() -> Int {
        if let profile = self.profile {
            switch profile.level {
            case 1...4:
                return 5
            case 5...10:
                return 10
            default:
                return 10
            }
        } else {
            return 10
        }
    }
}
