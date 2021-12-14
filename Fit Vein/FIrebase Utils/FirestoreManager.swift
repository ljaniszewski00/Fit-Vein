//
//  FirestoreManager.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 13/10/2021.
//

import Foundation
import Firebase
import SwiftUI
import grpc

class FirestoreManager: ObservableObject {
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    func getDatabase() -> Firestore {
        self.db
    }
    
    
    
    // Registration
    
    func signUpDataCreation(id: String, firstName: String, username: String, birthDate: Date, country: String, language: String, email: String, gender: String, completion: @escaping ((Profile) -> ())) {
        let documentData: [String: Any] = [
            "id": id,
            "firstName": firstName,
            "username": username,
            "birthDate": birthDate,
            "age": yearsBetweenDate(startDate: birthDate, endDate: Date()) == 0 ? 18 : yearsBetweenDate(startDate: birthDate, endDate: Date()),
            "country": country,
            "language": language,
            "email": email,
            "gender": gender
        ]
        
        self.db.collection("users").document(id).setData(documentData) { (error) in
            if let error = error {
                print("Error creating user's data: \(error.localizedDescription)")
            } else {
                print("Successfully created data for user: \(username) identifying with id: \(id) in database")
                completion(Profile(id: id, firstName: firstName, username: username, birthDate: birthDate, age: yearsBetweenDate(startDate: birthDate, endDate: Date()) == 0 ? 18 : yearsBetweenDate(startDate: birthDate, endDate: Date()), country: country,
                                   language: language, gender: gender, email: email, profilePictureURL: nil))
            }
        }
    }
    
    func checkUsernameDuplicate(username: String) async throws -> Bool {
        let querySnapshot = try await self.db.collection("users").whereField("username", isEqualTo: username).getDocuments()
        
        if querySnapshot.documents.count != 0 {
            return true
        } else {
            return false
        }
    }
    
    func checkEmailDuplicate(email: String) async throws -> Bool {
        let querySnapshot = try await self.db.collection("users").whereField("email", isEqualTo: email).getDocuments()
        
        if querySnapshot.documents.count != 0 {
            return true
        } else {
            return false
        }
    }
    
    
    
    // User
    
    func fetchDataForProfileViewModel(userID: String, completion: @escaping ((Profile?) -> ())) {

        self.db.collection("users").whereField("id", isEqualTo: userID).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error fetching profile data: \(error.localizedDescription)")
            } else {
                let profile = querySnapshot!.documents.map { (queryDocumentSnapshot) -> Profile in
                    let data = queryDocumentSnapshot.data()

                    let firstName = data["firstName"] as? String ?? ""
                    let username = data["username"] as? String ?? ""
                    let birthDate = data["birthDate"] as? Date ?? Date()
                    let age = data["age"] as? Int ?? 0
                    let country = data["country"] as? String ?? ""
                    let language = data["language"] as? String ?? ""
                    let gender = data["gender"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
                    let profilePictureURL = data["profilePictureURL"] as? String ?? nil

                    return Profile(id: userID, firstName: firstName, username: username, birthDate: birthDate, age: age, country: country, language: language, gender: gender, email: email, profilePictureURL: profilePictureURL)
                }
                
                DispatchQueue.main.async {
                    if profile.count != 0 {
                        completion(profile[0])
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func addProfilePictureURLToUsersData(photoURL: String, completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "profilePictureURL": photoURL
        ]
        
        updateUserData(documentData: documentData) {
            print("Successfully added new profile picture URL to database.")
            completion()
        }
    }
    
    func editUserEmailInDatabase(email: String, completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "email": email
        ]
        
        updateUserData(documentData: documentData) {
            print("Successfully updated user's email in database.")
            completion()
        }
    }
    
    func deleteUserData(userUID: String, completion: @escaping (() -> ())) {
        self.db.collection("users").document(userUID).delete() { (error) in
            if let error = error {
                print("Could not delete user data: \(error)")
            } else {
                completion()
            }
        }
    }
    
    
    
    // Followed
    
    func fetchFollowed(userID: String, completion: @escaping (([String]?) -> ())) {
        self.db.collection("users").document(userID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching followed users data: \(error.localizedDescription)")
            } else {
                if let document = document {
                    let followedUsers = document.get("followedUsers") as? [String] ?? nil
                    completion(followedUsers)
                }
            }
        }
    }
    
    func addUserToFollowed(userID: String, userIDToFollow: String, completion: @escaping (() -> ())) {
        self.fetchFollowed(userID: userID) { [self] fetchedFollowed in
            if let fetchedFollowed = fetchedFollowed {
                let documentData: [String: Any] = [
                    "followedUsers": fetchedFollowed
                ]
                updateUserData(documentData: documentData) {
                    print("Successfully updated followed users for the user \(userID)")
                    completion()
                }
            } else {
                let documentData: [String: Any] = [
                    "followedUsers": [userIDToFollow]
                ]
                updateUserData(documentData: documentData) {
                    print("Successfully added first followed user for the user \(userID)")
                    completion()
                }
            }
        }
    }
    
    func removeUserFromFollowed(userID: String, userIDToStopFollow: String, completion: @escaping (() -> ())) {
        self.fetchFollowed(userID: userID) { [self] fetchedFollowed in
            if let fetchedFollowed = fetchedFollowed {
                var fetchedFollowedToBeModified = fetchedFollowed
                for (index, fetchedFollowedUser) in fetchedFollowedToBeModified.enumerated() {
                    if fetchedFollowedUser == userIDToStopFollow {
                        fetchedFollowedToBeModified.remove(at: index)
                    }
                }
                fetchedFollowedToBeModified.sort() {
                    $0 < $1
                }
                let documentData: [String: Any] = [
                    "followedUsers": fetchedFollowedToBeModified
                ]
                updateUserData(documentData: documentData) {
                    print("Successfully removed user \(userIDToStopFollow) from user \(userID) followed users")
                    completion()
                }
            }
        }
    }
    
    
    
    // Posts
    
    func fetchPosts(userID: String, completion: @escaping (([Post]?) -> ())) {
        var fetchedPosts: [Post] = [Post]()

        self.fetchFollowed(userID: userID) { fetchedFollowed in
            var fetchedFollowedAndSelf = [String]()
            if fetchedFollowed == nil {
                fetchedFollowedAndSelf = [userID]
            } else {
                fetchedFollowedAndSelf = fetchedFollowed!
                fetchedFollowedAndSelf.append(userID)
            }
            print(fetchedFollowedAndSelf)
            self.db.collection("posts").whereField("authorID", in: fetchedFollowedAndSelf).addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching posts data: \(error.localizedDescription)")
                } else {
                    fetchedPosts = querySnapshot!.documents.map { (queryDocumentSnapshot) -> Post in
                        let data = queryDocumentSnapshot.data()

                        let id = data["id"] as? String ?? ""
                        let authorID = data["authorID"] as? String ?? ""
                        let authorFirstName = data["authorFirstName"] as? String ?? ""
                        let authorUsername = data["authorUsername"] as? String ?? ""
                        let authorProfilePictureURL = data["authorProfilePictureURL"] as? String ?? ""
                        let addDate = data["addDate"] as? Timestamp
                        let text = data["text"] as? String ?? ""
                        let reactionsNumber = data["reactionsNumber"] as? Int ?? 0
                        let commentsNumber = data["commentsNumber"] as? Int ?? 0

                        return Post(id: id, authorID: authorID, authorFirstName: authorFirstName, authorUsername: authorUsername, authorProfilePictureURL: authorProfilePictureURL, addDate: (addDate?.dateValue())!, text: text, reactionsNumber: reactionsNumber, commentsNumber: commentsNumber, comments: nil)
                    }
                    
                    DispatchQueue.main.async {
                        if fetchedPosts.count != 0 {
                            fetchedPosts.sort() {
                                $0.addDate < $1.addDate
                            }
                            completion(fetchedPosts)
                        } else {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
    
    func postDataCreation(id: String, authorID: String, authorFirstName: String, authorUsername: String, authorProfilePictureURL: String, addDate: Date, text: String, reactionsNumber: Int, commentsNumber: Int, comments: [Comment]?, completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "id": id,
            "authorID": authorID,
            "authorFirstName": authorFirstName,
            "authorUsername": authorUsername,
            "authorProfilePictureURL": authorProfilePictureURL,
            "addDate": Date(),
            "text": text,
            "reactionsNumber": reactionsNumber,
            "commentsNumber": commentsNumber
        ]
        
        self.db.collection("posts").document(id).setData(documentData) { (error) in
            if let error = error {
                print("Error creating post's data: \(error.localizedDescription)")
            } else {
                print("Successfully created post: \(id) by user: \(authorID)")
            }
        }
    }
    
    func postRemoval(id: String, completion: @escaping (() -> ())) {
        self.db.collection("posts").document(id).delete() { (error) in
            if let error = error {
                print("Error deleting post: \(error.localizedDescription)")
            } else {
                print("Successfully deleted post: \(id)")
            }
        }
    }
    
    
    
    // Comments
    
    
    
    
    
    //Workouts
    
    func fetchWorkouts(userID: String, completion: @escaping (([IntervalWorkout]?) -> ())) {
        var fetchedWorkouts: [IntervalWorkout] = [IntervalWorkout]()

        self.db.collection("workouts").whereField("usersID", isEqualTo: userID).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error fetching workouts data: \(error.localizedDescription)")
            } else {
                fetchedWorkouts = querySnapshot!.documents.map { (queryDocumentSnapshot) -> IntervalWorkout in
                    let data = queryDocumentSnapshot.data()

                    let id = data["id"] as? String ?? ""
                    let usersID = data["usersID"] as? String ?? ""
                    let type = data["type"] as? String ?? ""
                    let date = data["date"] as? Timestamp
                    let isFinished = data["isFinished"] as? Bool ?? true
                    let calories = data["calories"] as? Int? ?? 0
                    let series = data["series"] as? Int? ?? 0
                    let workTime = data["workTime"] as? Int? ?? 0
                    let restTime = data["restTime"] as? Int? ?? 0
                    let completedDuration = data["completedDuration"] as? Int? ?? 0
                    let completedSeries = data["completedSeries"] as? Int? ?? 0

                    return IntervalWorkout(forPreviews: false, id: id, usersID: usersID, type: type, date: (date?.dateValue())!, isFinished: isFinished, calories: calories, series: series, workTime: workTime, restTime: restTime, completedDuration: completedDuration, completedSeries: completedSeries)
                }
                
                DispatchQueue.main.async {
                    if fetchedWorkouts.count != 0 {
                        fetchedWorkouts.sort() {
                            $0.date < $1.date
                        }
                        completion(fetchedWorkouts)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func workoutDataCreation(id: String, usersID: String, type: String, date: Date, isFinished: Bool, calories: Int?, series: Int?, workTime: Int?, restTime: Int?, completedDuration: Int?, completedSeries: Int?, completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "id": id,
            "usersID": usersID,
            "type": type,
            "date": date,
            "isFinished": isFinished,
            "calories": calories,
            "series": series,
            "workTime": workTime,
            "restTime": restTime,
            "completedDuration": completedDuration,
            "completedSeries": completedSeries,
        ]
        
        self.db.collection("workouts").document(id).setData(documentData) { (error) in
            if let error = error {
                print("Error creating workout's data: \(error.localizedDescription)")
            } else {
                print("Successfully created data for workout: \(id) finished by user: \(usersID)")
            }
        }
    }
    
    
    
    // Universal
    
    private func updateUserData(documentData: [String: Any], completion: @escaping (() -> ())) {
        self.db.collection("users").document(user!.uid).updateData(documentData) { (error) in
            if let error = error {
                print("Error updating user's data: \(error.localizedDescription)")
            } else {
                completion()
            }
        }
    }
}
