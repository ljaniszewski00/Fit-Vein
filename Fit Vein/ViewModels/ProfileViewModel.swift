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
    
    @Published var workouts: [IntervalWorkout]?
    
    @Published var fetchingData = true
    
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
    
    func detachCurrentProfile() {
        self.profile = nil
    }
    
    func fetchData() {
        if sessionStore.currentUser != nil {
            self.firestoreManager.fetchDataForProfileViewModel(userID: self.sessionStore.currentUser!.uid) { [self] fetchedProfile in
                self.profile = fetchedProfile
                
                if profile != nil {
                    if profile!.profilePictureURL != nil {
                        if self.sessionStore.currentUser != nil {
                            self.firebaseStorageManager.getDownloadURLForImage(stringURL: profile!.profilePictureURL!, userID: self.sessionStore.currentUser!.uid) { photoURL, success in
                                if let photoURL = photoURL {
                                    self.profilePicturePhotoURL = photoURL
                                }
                                self.firestoreManager.fetchWorkouts(userID: self.sessionStore.currentUser!.uid) { fetchedWorkouts, success in
                                    if success {
                                        self.workouts = fetchedWorkouts
                                        self.fetchingData = false
                                    }
                                }
                            }
                        }
                    } else {
                        self.fetchingData = false
                    }
                } else {
                    self.fetchingData = false
                }
            }
        } else {
            self.fetchingData = false
        }
    }
    
    func uploadPhoto(image: UIImage, completion: @escaping ((Bool) -> ())) {
        if let profile = self.profile {
            if let profilePictureURL = profile.profilePictureURL {
                self.firebaseStorageManager.deleteImageFromStorage(userPhotoURL: profile.profilePictureURL!, userID: profile.id) { success in }
            }
            
            print("Uploading photo for user ID: \(self.sessionStore.currentUser!.uid)")
            
            self.firebaseStorageManager.uploadImageToStorage(image: image, userID: profile.id) { photoURL, success in
                if success {
                    if let photoURL = photoURL {
                        self.firestoreManager.addProfilePictureURLToUsersData(photoURL: photoURL) { success in
                            if success {
                                self.firestoreManager.postChangeAuthorProfilePictureURL(authorID: profile.id, authorProfilePictureURL: photoURL) { success in
                                    if success {
                                        self.firestoreManager.commentChangeAuthorProfilePictureURL(authorID: profile.id, authorProfilePictureURL: photoURL) { success in
                                            self.fetchData()
                                            completion(success)
                                        }
                                    } else {
                                        self.fetchData()
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
                    self.fetchData()
                }
                completion(success)
            }
        }
    }
    
    func unfollowUser(userID: String, completion: @escaping ((Bool) -> ())) {
        if sessionStore.currentUser != nil {
            self.firestoreManager.removeUserFromFollowed(userID: self.sessionStore.currentUser!.uid, userIDToStopFollow: userID) { success in
                if success {
                    self.fetchData()
                }
                completion(success)
            }
        }
    }
}
