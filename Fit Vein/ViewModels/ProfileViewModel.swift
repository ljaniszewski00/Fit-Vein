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
    @Published var sessionStore = SessionStore(forPreviews: false)
    private let firestoreManager = FirestoreManager()
    private let firebaseStorageManager = FirebaseStorageManager()
    
    private var healthKitRepository = HealthKitRepository()
    @Published var stepCount = [HealthStat]()
    @Published var activeEnergyBurned = [HealthStat]()
    @Published var distanceWalkingRunning = [HealthStat]()
    @Published var appleExerciseTime = [HealthStat]()
    @Published var heartRate = [HealthStat]()
    
    @Published var profile: Profile?
    @Published var profilePicturePhotoURL: URL?
    
    @Published var workouts: [IntervalWorkout]?
    
    @Published var fetchingData = true
    
    init(forPreviews: Bool) {
        self.workouts = [IntervalWorkout(forPreviews: true, id: UUID().uuidString, type: "Interval", date: Date(), isFinished: true, calories: 200, series: 8, workTime: 45, restTime: 15, completedDuration: 8 * (45 + 15), completedSeries: 8),
                         IntervalWorkout(forPreviews: true, id: UUID().uuidString, type: "Interval", date: Date(), isFinished: true, calories: 260, series: 10, workTime: 45, restTime: 15, completedDuration: 8 * (45 + 15), completedSeries: 8),
                         IntervalWorkout(forPreviews: true, id: UUID().uuidString, type: "Interval", date: Date(), isFinished: true, calories: 140, series: 6, workTime: 45, restTime: 15, completedDuration: 8 * (45 + 15), completedSeries: 8),
                         IntervalWorkout(forPreviews: true, id: UUID().uuidString, type: "Interval", date: Date(), isFinished: true, calories: 110, series: 5, workTime: 45, restTime: 15, completedDuration: 8 * (45 + 15), completedSeries: 8),
                         IntervalWorkout(forPreviews: true, id: UUID().uuidString, type: "Interval", date: Date(), isFinished: true, calories: 260, series: 10, workTime: 45, restTime: 15, completedDuration: 8 * (45 + 15), completedSeries: 8)]
        
        self.profile = Profile(id: "sessionStore!.currentUser!.uid", firstName: "firstname", username: "username", birthDate: Date(), age: 18, country: "country", language: "language", gender: "gender", email: "email", profilePictureURL: nil)
        
        DispatchQueue.main.async {
            self.healthKitRepository.requestAuthorization() { success in
                print("Auth success: \(success)")
            }
            
            self.healthKitRepository.requestHealthStats(by: "stepCount") { hStats in
                self.stepCount = hStats
            }
            
            self.healthKitRepository.requestHealthStats(by: "activeEnergyBurned") { hStats in
                self.activeEnergyBurned = hStats
            }
            
            self.healthKitRepository.requestHealthStats(by: "distanceWalkingRunning") { hStats in
                self.distanceWalkingRunning = hStats
            }
            
            self.healthKitRepository.requestHealthStats(by: "appleExerciseTime") { hStats in
                self.appleExerciseTime = hStats
            }
            
            self.healthKitRepository.requestHealthStats(by: "heartRate") { hStats in
                self.heartRate = hStats
            }
            
            
        }
    }
    
    init() {
        // to be removed
        self.workouts = [IntervalWorkout(forPreviews: true, id: UUID().uuidString, type: "Interval", date: Date(), isFinished: true, calories: 200, series: 8, workTime: 45, restTime: 15, completedDuration: 8 * (45 + 15), completedSeries: 8),
                         IntervalWorkout(forPreviews: true, id: UUID().uuidString, type: "Interval", date: Date(), isFinished: true, calories: 260, series: 10, workTime: 45, restTime: 15, completedDuration: 8 * (45 + 15), completedSeries: 8),
                         IntervalWorkout(forPreviews: true, id: UUID().uuidString, type: "Interval", date: Date(), isFinished: true, calories: 140, series: 6, workTime: 45, restTime: 15, completedDuration: 8 * (45 + 15), completedSeries: 8),
                         IntervalWorkout(forPreviews: true, id: UUID().uuidString, type: "Interval", date: Date(), isFinished: true, calories: 110, series: 5, workTime: 45, restTime: 15, completedDuration: 8 * (45 + 15), completedSeries: 8),
                         IntervalWorkout(forPreviews: true, id: UUID().uuidString, type: "Interval", date: Date(), isFinished: true, calories: 260, series: 10, workTime: 45, restTime: 15, completedDuration: 8 * (45 + 15), completedSeries: 8)]
        //
        
        fetchData()
        
        DispatchQueue.main.async {
            self.healthKitRepository.requestAuthorization() { success in
                print("Auth success: \(success)")
            }
            
            self.healthKitRepository.requestHealthStats(by: "stepCount") { hStats in
                self.stepCount = hStats
            }
            
            self.healthKitRepository.requestHealthStats(by: "activeEnergyBurned") { hStats in
                self.activeEnergyBurned = hStats
            }
            
            self.healthKitRepository.requestHealthStats(by: "distanceWalkingRunning") { hStats in
                self.distanceWalkingRunning = hStats
            }
            
            self.healthKitRepository.requestHealthStats(by: "appleExerciseTime") { hStats in
                self.appleExerciseTime = hStats
            }
            
            self.healthKitRepository.requestHealthStats(by: "heartRate") { hStats in
                self.heartRate = hStats
            }
        }
    }
    
    func setup(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }
    
    func detachCurrentProfile() {
        self.profile = nil
    }
    
    func fetchData() {
        if sessionStore != nil {
            if sessionStore.currentUser != nil {
                print()
                print()
                print("Starting fetching data")
                print()
                print()
                self.firestoreManager.fetchDataForProfileViewModel(userID: self.sessionStore.currentUser!.uid) { profile in
                    self.profile = profile
                    
                    if profile != nil {
                        if profile!.profilePictureURL != nil {
                            print()
                            print()
                            print("Profile picture URL is not nil while fetching data")
                            print()
                            print()
                            self.firebaseStorageManager.getDownloadURLForImage(stringURL: profile!.profilePictureURL!, userID: self.sessionStore.currentUser!.uid) { photoURL in
                                self.profilePicturePhotoURL = photoURL
                                self.fetchingData = false
                            }
                        } else {
                            self.fetchingData = false
                        }
                    } else {
                        // "HERE SOMETHING TO DO WHEN DATA IS NOT FETCHED"
                        
                        self.fetchingData = false
                    }
                }
            }
        } else {
            print()
            print()
            print("Data is not fetching because sessionStore is nil")
            print()
            print()
            self.fetchingData = false
        }
    }
    
    func uploadPhoto(image: UIImage) {
        if self.profile!.profilePictureURL != nil {
            self.firebaseStorageManager.deleteImageFromStorage(userPhotoURL: self.profile!.profilePictureURL!, userID: self.sessionStore.currentUser!.uid) {}
        }
        
        print("Uploading photo for user ID: \(self.sessionStore.currentUser!.uid)")
        
        self.firebaseStorageManager.uploadImageToStorage(image: image, userID: self.sessionStore.currentUser!.uid) { photoURL in
            self.firestoreManager.addProfilePictureURLToUsersData(photoURL: photoURL) {
                self.fetchData()
            }
        }
    }
    
    func emailAddressChange(oldEmailAddress: String, password: String, newEmailAddress: String, completion: @escaping (() -> ())) {
        self.sessionStore.changeEmailAddress(oldEmailAddress: oldEmailAddress, password: password, newEmailAddress: newEmailAddress) {
            print("Successfully changed user's e-mail address")
        }
    }
    
    func passwordChange(emailAddress: String, oldPassword: String, newPassword: String, completion: @escaping (() -> ())) {
        self.sessionStore.changePassword(emailAddress: emailAddress, oldPassword: oldPassword, newPassword: newPassword) {
            print("Successfully changed user's password")
        }
    }
    
    func deleteUserData(completion: @escaping (() -> ())) {
        if self.profile != nil {
            if self.profile!.profilePictureURL != nil {
                self.firebaseStorageManager.deleteImageFromStorage(userPhotoURL: self.profile!.profilePictureURL!, userID: self.sessionStore.currentUser!.uid) {
                    self.firestoreManager.deleteUserData(userUID: self.sessionStore.currentUser!.uid) {
                        print("Successfully deleted user data")
                        completion()
                    }
                }
            }
        }
    }
}
