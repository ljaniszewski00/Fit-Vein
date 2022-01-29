//
//  FirestoreManager.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 13/10/2021.
//

import Foundation
import Firebase
import SwiftUI

class FirestoreManager: ObservableObject {
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    func getDatabase() -> Firestore {
        self.db
    }
    
    // Registration
    
    func signUpDataCreation(id: String, firstName: String, username: String, birthDate: Date, country: String, language: String, email: String, gender: String, completion: @escaping ((Profile?, Bool) -> ())) {
        let documentData: [String: Any] = [
            "id": id,
            "firstName": firstName,
            "username": username.lowercased(),
            "birthDate": birthDate,
            "age": yearsBetweenDate(startDate: birthDate, endDate: Date()) == 0 ? 18 : yearsBetweenDate(startDate: birthDate, endDate: Date()),
            "country": country,
            "language": language,
            "email": email.lowercased(),
            "gender": gender,
            "followedUsers": [String](),
            "reactedPostsIDs": [String](),
            "commentedPostsIDs": [String](),
            "reactedCommentsIDs": [String](),
            "completedWorkouts": 0,
            "level": 1,
            "medals": ["medalFirstLevel"]
        ]
        
        self.db.collection("users").document(id).setData(documentData) { (error) in
            if let error = error {
                print("Error creating user's data: \(error.localizedDescription)")
                completion(nil, false)
            } else {
                print("Successfully created data for user: \(username) identifying with id: \(id) in database")
                completion(Profile(id: id, firstName: firstName, username: username, birthDate: birthDate, age: yearsBetweenDate(startDate: birthDate, endDate: Date()) == 0 ? 18 : yearsBetweenDate(startDate: birthDate, endDate: Date()), country: country, language: language, gender: gender, email: email, profilePictureURL: nil, followedIDs: nil, reactedPostsIDs: nil, commentedPostsIDs: nil, completedWorkouts: 0, level: 0), true)
            }
        }
    }
    
    func checkUsernameDuplicate(username: String) async throws -> Bool {
        let querySnapshot = try await self.db.collection("users").whereField("username", isEqualTo: username.lowercased()).getDocuments()
        
        if querySnapshot.documents.count != 0 {
            return true
        } else {
            return false
        }
    }
    
    func checkEmailDuplicate(email: String) async throws -> Bool {
        let querySnapshot = try await self.db.collection("users").whereField("email", isEqualTo: email.lowercased()).getDocuments()
        
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
                    let followedIDs = data["followedUsers"] as? [String]? ?? nil
                    let reactedPostsIDs = data["reactedPostsIDs"] as? [String]? ?? nil
                    let commentedPostsIDs = data["commentedPostsIDs"] as? [String]? ?? nil
                    let reactedCommentsIDs = data["reactedCommentsIDs"] as? [String]? ?? nil
                    let completedWorkouts = data["completedWorkouts"] as? Int ?? 0
                    let level = data["level"] as? Int ?? 1

                    return Profile(id: userID, firstName: firstName, username: username, birthDate: birthDate, age: age, country: country, language: language, gender: gender, email: email, profilePictureURL: profilePictureURL, followedIDs: followedIDs, reactedPostsIDs: reactedPostsIDs, commentedPostsIDs: commentedPostsIDs, reactedCommentsIDs: reactedCommentsIDs, completedWorkouts: completedWorkouts, level: level)
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
    
    func addProfilePictureURLToUsersData(photoURL: String, completion: @escaping ((Bool) -> ())) {
        let documentData: [String: Any] = [
            "profilePictureURL": photoURL
        ]
        
        updateUserData(documentData: documentData) { success in
            if success {
                print("Successfully added new profile picture URL to database.")
            } else {
                print("Error adding new profile picture URL to database.")
            }
            completion(success)
        }
    }
    
    func editUserEmailInDatabase(userID: String, email: String, completion: @escaping ((Bool) -> ())) {
        let documentData: [String: Any] = [
            "email": email
        ]
        
        updateUserData(documentData: documentData) { success in
            if success {
                print("Successfully edited user's e-mail in database.")
            } else {
                print("Error editing user's e-mail in database.")
            }
            completion(success)
        }
    }
    
    func deleteUserData(userID: String, completion: @escaping ((Bool) -> ())) {
        let queue = DispatchQueue(label: "SerialQueue")
        
        queue.async {
            //Firstly, delete the id of user, who is deleting his/her account, from arrays of followed ids of all users who followed this user
            self.db.collection("users").whereField("followedUsers", arrayContains: userID).getDocuments() { (querySnapshot, error) in
                if let error = error {
                    print("Error getting users for followed users modify when user deletes his account: \(error.localizedDescription)")
                } else {
                    for userDocument in querySnapshot!.documents {
                        print()
                        print("Teraz printuje dokument, w którym usunę followedID")
                        print(userDocument.documentID)
                        print()
                        self.removeUserFromFollowed(userID: userDocument.documentID, userIDToStopFollow: userID) { success in
                            if success {
                                print("Successfully removed user's id from users ids followed by user \(userDocument.documentID)")
                            } else {
                                print("Error removing user's id from users ids followed by user \(userDocument.documentID)")
                            }
                        }
                    }
                }
            }
            
            //Secondly, delete all activity made by user - his comments, his workouts and his posts, including the reactions
            for collection in ["comments", "workouts", "posts"] {
                self.db.collection(collection).whereField(["comments", "posts"].contains(collection) ? "authorID" : "usersID", isEqualTo: userID).getDocuments() { (querySnapshot, error) in
                    if let error = error {
                        //If user has not made some activity in particular collection print the error and go to deleting his data from other collections
                        switch collection {
                        case "comments":
                            print("Error getting documents ids for deleting user comments: \(error.localizedDescription)")
                        case "workouts":
                            print("Error getting documents ids for deleting user workouts: \(error.localizedDescription)")
                        case "posts":
                            print("Error getting documents ids for deleting user posts: \(error.localizedDescription)")
                        default:
                            print()
                        }
                    } else {
                        //If user has made some activity in particular collection
                        for document in querySnapshot!.documents {
                            // Delete all documents in 'comments', 'posts' and 'workouts' collection that is created by user who deletes his/her account
                            self.db.collection(collection).document(document.documentID).delete() { (error) in
                                if let error = error {
                                    switch collection {
                                    case "comments":
                                        print("Error deleting user comment: \(error.localizedDescription)")
                                    case "workouts":
                                        print("Error deleting user workout: \(error.localizedDescription)")
                                    case "posts":
                                        print("Error deleting user post: \(error.localizedDescription)")
                                    default:
                                        print()
                                    }
                                } else {
                                    switch collection {
                                    case "comments":
                                        // Remove previously deleted commentID from user's reacted comments
                                        self.db.collection("users").whereField("reactedCommentsIDs", arrayContains: document.documentID).getDocuments() { (querySnapshot, error) in
                                            if let error = error {
                                                print("Error getting users for reacted comments modify upon comment removal when user deletes his account: \(error.localizedDescription)")
                                            } else {
                                                for userDocument in querySnapshot!.documents {
                                                    self.removeCommentIDFromCommentsReactedByUser(userID: userDocument.documentID, commentID: document.documentID) { success in
                                                        if success {
                                                            print("Successfully removed comment's id from comments ids reacted by user: \(userDocument.documentID)")
                                                        } else {
                                                            print("Error removing comment's id from comments ids reacted by user: \(userDocument.documentID)")
                                                        }
                                                        
                                                    }
                                                }
                                            }
                                        }
                                    case "posts":
                                        // Remove previously deleted post's postID from user's reacted posts
                                        self.db.collection("users").whereField("reactedPostsIDs", arrayContains: document.documentID).getDocuments() { (querySnapshot, error) in
                                            if let error = error {
                                                print("Error getting users for reacted posts modify upon comment removal when user deletes his account: \(error.localizedDescription)")
                                            } else {
                                                for userDocument in querySnapshot!.documents {
                                                    self.removePostIDFromPostsReactedByUser(userID: userDocument.documentID, postID: document.documentID) { success in
                                                        if success {
                                                            print("Successfully removed post id from post ids reacted by user: \(userDocument.documentID)")
                                                        } else {
                                                            print("Error removing post id from post ids reacted by user: \(userDocument.documentID)")
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        // Remove previously deleted post's postID from user's commented posts
                                        self.db.collection("users").whereField("commentedPostsIDs", arrayContains: document.documentID).getDocuments() { (querySnapshot, error) in
                                            if let error = error {
                                                print("Error getting users for commented posts modify upon comment removal when user deletes his account: \(error.localizedDescription)")
                                            } else {
                                                for userDocument in querySnapshot!.documents {
                                                    self.removePostIDFromPostsCommentedByUser(userID: userDocument.documentID, postID: document.documentID) { success in
                                                        if success {
                                                            print("Successfully removed post id from post ids commented by user: \(userDocument.documentID)")
                                                        } else {
                                                            print("Error removing post id from post ids commented by user: \(userDocument.documentID)")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    default:
                                        print()
                                    }
                                }
                            }
                        }
                    }
                }
                
                self.db.collection(collection).getDocuments() { (querySnapshot, error) in
                    if let error = error {
                        //If user has not made some activity in particular collection print the error and go to deleting his data from 'users' collection
                        switch collection {
                        case "comments":
                            print("Error getting documents ids for deleting user comments: \(error.localizedDescription)")
                        case "workouts":
                            print("Error getting documents ids for deleting user workouts: \(error.localizedDescription)")
                        case "posts":
                            print("Error getting documents ids for deleting user posts: \(error.localizedDescription)")
                        default:
                            print()
                        }
                    } else {
                        //If user has made some activity in particular collection
                        for document in querySnapshot!.documents {
                            switch collection {
                            case "comments":
                                self.commentRemoveReaction(commentID: document.documentID, userIDThatRemovedReaction: userID) { _ in }
                            case "posts":
                                self.postRemoveCommentingUserID(postID: document.documentID, userIDThatRemovedComment: userID) { success in
                                    if success {
                                        self.postRemoveReaction(postID: document.documentID, userIDThatRemovedReaction: userID) { _ in }
                                    }
                                }
                            default:
                                print()
                            }
                        }
                    }
                }
            }
        }
        
        queue.async {
            //Finally, delete user from 'users' collection
            self.deleteUserExistence(userID: userID) { success in
                if success {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    private func deleteUserExistence(userID: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("users").document(userID).delete() { (error) in
            if let error = error {
                print("Error deleting user's data: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Successfully deleted user's data")
                completion(true)
            }
        }
    }
    
    func addPostIDToPostsReactedByUser(userID: String, postID: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for adding postID to posts reacted by user: \(error.localizedDescription)")
                completion(false)
            } else {
                if let document = document {
                    let reactedPostsIDs = document.get("reactedPostsIDs") as? [String]? ?? nil
                    
                    if let reactedPostsIDs = reactedPostsIDs {
                        if !reactedPostsIDs.contains(postID) {
                            var newReactionsPostsIDs = reactedPostsIDs
                            newReactionsPostsIDs.append(postID)
                            
                            let documentData: [String: Any] = [
                                "reactedPostsIDs": newReactionsPostsIDs
                            ]
                            updateUserData(documentData: documentData) { success in
                                if success {
                                    print("Successfully added post \(postID) to posts reacted by user")
                                    completion(true)
                                } else {
                                    print("Error adding post \(postID) to posts reacted by user")
                                    completion(false)
                                }
                            }
                        } else {
                            print("Post \(postID) was not added to posts reacted by user because it has already been reacted before.")
                            completion(false)
                        }
                    }
                }
            }
        }
    }
    
    func removePostIDFromPostsReactedByUser(userID: String, postID: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for removing postID from posts reacted by user: \(error.localizedDescription)")
                completion(false)
            } else {
                if let document = document {
                    let reactedPostsIDs = document.get("reactedPostsIDs") as? [String]? ?? nil
            
                    if let reactedPostsIDs = reactedPostsIDs {
                        if reactedPostsIDs.contains(postID) {
                            var newReactionsPostsIDs = [String]()
                            for reactionsPostID in reactedPostsIDs {
                                if !(reactionsPostID == postID) {
                                    newReactionsPostsIDs.append(reactionsPostID)
                                }
                            }
                            
                            let documentData: [String: Any] = [
                                "reactedPostsIDs": newReactionsPostsIDs
                            ]
                            updateUserData(documentData: documentData) { success in
                                if success {
                                    print("Successfully removed post \(postID) from posts reacted by user")
                                    completion(true)
                                } else {
                                    print("Error removing post \(postID) from posts reacted by user")
                                    completion(false)
                                }
                            }
                        } else {
                            print("Post \(postID) was not removed from posts reacted by user becuase it hasn't been reacted before.")
                            completion(false)
                        }
                    }
                }
            }
        }
    }
    
    func addPostIDToPostsCommentedByUser(userID: String, postID: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for adding commented post by user: \(error.localizedDescription)")
                completion(false)
            } else {
                if let document = document {
                    let commentedPostsIDs = document.get("commentedPostsIDs") as? [String]? ?? nil
                    
                    if let commentedPostsIDs = commentedPostsIDs {
                        if !commentedPostsIDs.contains(postID) {
                            var newCommentedPostsIDs = commentedPostsIDs
                            newCommentedPostsIDs.append(postID)
                            
                            let documentData: [String: Any] = [
                                "commentedPostsIDs": newCommentedPostsIDs
                            ]
                            updateUserData(documentData: documentData) { success in
                                if success {
                                    print("Successfully added post \(postID) to posts commented by user")
                                    completion(true)
                                } else {
                                    print("Error adding post \(postID) to posts commented by user")
                                }
                            }
                        } else {
                            print("Post \(postID) was not added to posts commented by user because it has already been commented before.")
                            completion(false)
                        }
                    }
                }
            }
        }
    }
    
    func removePostIDFromPostsCommentedByUser(userID: String, postID: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for removing commented post by user: \(error.localizedDescription)")
                completion(false)
            } else {
                if let document = document {
                    let commentedPostsIDs = document.get("commentedPostsIDs") as? [String]? ?? nil
                    
                    if let commentedPostsIDs = commentedPostsIDs {
                        if commentedPostsIDs.contains(postID) {
                            var newCommentedPostsIDs = [String]()
                            for commentedPostID in commentedPostsIDs {
                                if !(commentedPostID == postID) {
                                    newCommentedPostsIDs.append(commentedPostID)
                                }
                            }
                            
                            let documentData: [String: Any] = [
                                "commentedPostsIDs": newCommentedPostsIDs
                            ]
                            updateUserData(documentData: documentData) { success in
                                if success {
                                    print("Successfully removed post \(postID) from posts commented by user")
                                    completion(true)
                                } else {
                                    print("Error removing post \(postID) from posts commented by user")
                                }
                            }
                        } else {
                            print("Post \(postID) was not removed from posts commented by user becuase it hasn't been commented before.")
                            completion(false)
                        }
                    }
                }
            }
        }
    }
    
    func addCommentIDToCommentsReactedByUser(userID: String, commentID: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for adding reacted comment for user: \(error.localizedDescription)")
                completion(false)
            } else {
                if let document = document {
                    let reactedCommentsIDs = document.get("reactedCommentsIDs") as? [String]? ?? nil
                    
                    if let reactedCommentsIDs = reactedCommentsIDs {
                        if !reactedCommentsIDs.contains(commentID) {
                            var newReactedCommentsIDs = reactedCommentsIDs
                            newReactedCommentsIDs.append(commentID)
                            
                            let documentData: [String: Any] = [
                                "reactedCommentsIDs": newReactedCommentsIDs
                            ]
                            updateUserData(documentData: documentData) { success in
                                if success {
                                    print("Successfully added comment \(commentID) to comments reacted by user")
                                    completion(true)
                                } else {
                                    print("Error adding comment \(commentID) to comments reacted by user")
                                    completion(false)
                                }
                            }
                        } else {
                            print("Comment \(commentID) was not added to comments reacted by user because it has already been reacted before.")
                            completion(false)
                        }
                    }
                }
            }
        }
    }
    
    func removeCommentIDFromCommentsReactedByUser(userID: String, commentID: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for removing reacted comment for user: \(error.localizedDescription)")
                completion(false)
            } else {
                if let document = document {
                    let reactedCommentsIDs = document.get("reactedCommentsIDs") as? [String]? ?? nil
                    
                    if let reactedCommentsIDs = reactedCommentsIDs {
                        if reactedCommentsIDs.contains(commentID) {
                            var newReactedCommentsIDs = [String]()
                            for reactedCommentID in reactedCommentsIDs {
                                if !(reactedCommentID == commentID) {
                                    newReactedCommentsIDs.append(reactedCommentID)
                                }
                            }
                            
                            let documentData: [String: Any] = [
                                "reactedCommentsIDs": newReactedCommentsIDs
                            ]
                            updateUserData(documentData: documentData) { success in
                                if success {
                                    print("Successfully removed comment \(commentID) from comments reacted by user")
                                    completion(true)
                                } else {
                                    print("Error removing comment \(commentID) from comments reacted by user")
                                    completion(false)
                                }
                            }
                        } else {
                            print("Comment \(commentID) was not removed from comments reacted by user becuase it hasn't been reacted before.")
                            completion(false)
                        }
                    }
                }
            }
        }
    }
    
    func addCompletedWorkout(userID: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for adding completed workout: \(error.localizedDescription)")
                completion(false)
            } else {
                if let document = document {
                    var completedWorkouts = document.get("completedWorkouts") as? Int ?? 0
                    completedWorkouts += 1
                    
                    /*
                     User levels up in the following scheme:
                        levels 1
                        new level after 2 workouts
                    
                        level 2
                        new level after 3 workouts
                    
                        level 3 is achieved after 5 workout total and is maximum level for now.
                     */
                    
                    let documentData: [String: Any] = [
                        "completedWorkouts": completedWorkouts
                    ]
                    updateUserData(documentData: documentData) { success in
                        if success {
                            print("Successfully added completed workout for user \(userID)")
                            
                            if [2, 5].contains(completedWorkouts) {
                                self.levelUpUser(userID: userID) { success in
                                    completion(success)
                                }
                                
                                switch completedWorkouts {
                                case 2:
                                    self.giveUserMedal(userID: userID, medalName: "medalSecondLevel") { success in }
                                case 5:
                                    self.giveUserMedal(userID: userID, medalName: "medalThirdLevel") { success in }
                                default:
                                    print("No medal to give upon leveling up the user.")
                                }
                                
                            } else {
                                completion(true)
                            }
                        } else {
                            print("Error adding completed workout for user \(userID)")
                            completion(false)
                        }
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func levelUpUser(userID: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for leveling up the user: \(error.localizedDescription)")
                completion(false)
            } else {
                if let document = document {
                    var userLevel = document.get("level") as? Int ?? 1
                    userLevel += 1
                    
                    let documentData: [String: Any] = [
                        "level": userLevel
                    ]
                    updateUserData(documentData: documentData) { success in
                        if success {
                            print("Successfully leveled up user \(userID)")
                            UserDefaults.standard.set(true, forKey: "shouldShowLevelUpAnimation")
                            completion(true)
                        } else {
                            print("Error leveling up user \(userID)")
                            completion(false)
                        }
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    
    
    // Medals
    
    func fetchDataForMedalsViewModel(userID: String, completion: @escaping (([String]) -> ())) {
        self.db.collection("users").whereField("id", isEqualTo: userID).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error fetching medals data: \(error.localizedDescription)")
            } else {
                if let querySnapshot = querySnapshot {
                    if !querySnapshot.documents.isEmpty {
                        let data = querySnapshot.documents[0].data()
                        let medals = data["medals"] as? [String] ?? [String]()
                        
                        completion(medals)
                    } else {
                        completion([String]())
                    }
                }
            }
        }
    }
    
    func giveUserMedal(userID: String, medalName: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for giving user medal: \(error.localizedDescription)")
                completion(false)
            } else {
                if let document = document {
                    var medals = document.get("medals") as? [String] ?? [String]()
                    medals.append(medalName)
                    
                    let documentData: [String: Any] = [
                        "medals": medals
                    ]
                    updateUserData(documentData: documentData) { success in
                        completion(success)
                    }
                } else {
                    completion(false)
                }
            }
        }
    }

    
    // Followed
    
    func fetchFollowed(userID: String, completion: @escaping (([String]?, Bool) -> ())) {
        self.db.collection("users").document(userID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching followed users data: \(error.localizedDescription)")
                completion(nil, false)
            } else {
                if let document = document {
                    let followedUsers = document.get("followedUsers") as? [String] ?? nil
                    completion(followedUsers, true)
                } else {
                    completion(nil, false)
                }
            }
        }
    }
    
    func addUserToFollowed(userID: String, userIDToFollow: String, completion: @escaping ((Bool) -> ())) {
        self.fetchFollowed(userID: userID) { fetchedFollowed, success in
            if success {
                if let fetchedFollowed = fetchedFollowed {
                    if !fetchedFollowed.contains(userIDToFollow) {
                        var fetchedFollowedToBeModified = fetchedFollowed
                        fetchedFollowedToBeModified.append(userIDToFollow)
                        let documentData: [String: Any] = [
                            "followedUsers": fetchedFollowedToBeModified
                        ]
                        self.updateUserData(documentData: documentData) { success in
                            if success {
                                print("Successfully added user \(userIDToFollow) to users followed by the user \(userID)")
                                completion(true)
                            } else {
                                print("Error adding user \(userIDToFollow) to users followed by the user \(userID)")
                                completion(false)
                            }
                            
                        }
                    } else {
                        print("User \(userIDToFollow) was not added to users followed by the user \(userID) because he has already been followed before")
                        completion(false)
                    }
                } else {
                    let documentData: [String: Any] = [
                        "followedUsers": [userIDToFollow]
                    ]
                    self.updateUserData(documentData: documentData) { success in
                        if success {
                            print("Successfully added first user \(userIDToFollow) to users followed by the user \(userID)")
                            completion(true)
                        } else {
                            print("Error adding first user \(userIDToFollow) to users followed by the user \(userID)")
                            completion(false)
                        }
                        
                    }
                }
            } else {
                completion(false)
            }
        }
    }
    
    func removeUserFromFollowed(userID: String, userIDToStopFollow: String, completion: @escaping ((Bool) -> ())) {
        self.fetchFollowed(userID: userID) { fetchedFollowed, success in
            if success {
                if let fetchedFollowed = fetchedFollowed {
                    print()
                    print("Teraz wypiszę fetchFollowed:")
                    print(fetchedFollowed)
                    print()
                    if fetchedFollowed.contains(userIDToStopFollow) {
                        var fetchedFollowedToBeModified = [String]()
                        for fetchedFollowedUserID in fetchedFollowed {
                            print()
                            print("Teraz wyśwetlę każde userID z fetchedFollowed ponieważ usedID który chce usunąć jest w fetchedFollowed")
                            print(fetchedFollowedUserID)
                            print()
                            if !(fetchedFollowedUserID == userIDToStopFollow) {
                                fetchedFollowedToBeModified.append(fetchedFollowedUserID)
                            } else {
                                print()
                                print("Znalazłem fetchedFollowed do usunięcia")
                                print("\(fetchedFollowedUserID) is the user to be deleted")
                                print()
                            }
                        }
                        print()
                        print("Do bazy zostanie zapisana lista fetchedFollowedToBeModified: \(fetchedFollowedToBeModified)")
                        print()
                        print()
                        
                        let documentData: [String: Any] = [
                            "followedUsers": fetchedFollowedToBeModified
                        ]
                        self.updateUserData(documentData: documentData) { success in
                            if success {
                                print("Successfully removed user \(userIDToStopFollow) from user \(userID) followed users")
                                completion(true)
                            } else {
                                print("Error removing user \(userIDToStopFollow) from user \(userID) followed users")
                                completion(false)
                            }
                            
                        }
                    } else {
                        print("User \(userIDToStopFollow) was not removed from users followed by the user \(userID) because he hasn't been followed before")
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    
    
    // Posts
    
    func fetchPosts(userID: String, completion: @escaping (([Post]?, Bool) -> ())) {
        var fetchedPosts: [Post] = [Post]()

        self.fetchFollowed(userID: userID) { fetchedFollowed, success in
            var fetchedFollowedAndSelf = [String]()
            if let fetchedFollowed = fetchedFollowed {
                if fetchedFollowed.isEmpty {
                    fetchedFollowedAndSelf.append(userID)
                } else {
                    fetchedFollowedAndSelf = fetchedFollowed
                    fetchedFollowedAndSelf.append(userID)
                }
            } else {
                fetchedFollowedAndSelf = [userID]
            }
            self.db.collection("posts").whereField("authorID", in: fetchedFollowedAndSelf).addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching posts data: \(error.localizedDescription)")
                    completion(nil, false)
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
                        let reactionsUsersIDs = data["reactionsUsersIDs"] as? [String]? ?? nil
                        let commentedUsersIDs = data["commentedUsersIDs"] as? [String]? ?? nil
                        let photoURL = data["photoURL"] as? String? ?? nil

                        return Post(id: id, authorID: authorID, authorFirstName: authorFirstName, authorUsername: authorUsername, authorProfilePictureURL: authorProfilePictureURL, addDate: (addDate?.dateValue())!, text: text, reactionsUsersIDs: reactionsUsersIDs, commentedUsersIDs: commentedUsersIDs, comments: nil, photoURL: photoURL)
                    }
                    
                    DispatchQueue.main.async {
                        if fetchedPosts.count != 0 {
                            fetchedPosts.sort() {
                                $0.addDate > $1.addDate
                            }
                            completion(fetchedPosts, true)
                        } else {
                            completion(nil, false)
                        }
                    }
                }
            }
        }
    }
    
    func postDataCreation(id: String, authorID: String, authorFirstName: String, authorUsername: String, authorProfilePictureURL: String, addDate: Date, text: String, reactionsUsersIDs: [String]?, comments: [Comment]?, photoURL: String? = nil, completion: @escaping ((Bool) -> ())) {
        let documentData: [String: Any] = [
            "id": id,
            "authorID": authorID,
            "authorFirstName": authorFirstName,
            "authorUsername": authorUsername,
            "authorProfilePictureURL": authorProfilePictureURL,
            "addDate": Date(),
            "text": text,
            "reactionsUsersIDs": reactionsUsersIDs as Any,
            "commentedUsersIDs": reactionsUsersIDs as Any,
            "photoURL": photoURL as Any
        ]
        
        self.db.collection("posts").document(id).setData(documentData) { (error) in
            if let error = error {
                print("Error creating post's data: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Successfully created post: \(id) by user: \(authorID)")
                completion(true)
            }
        }
    }
    
    func addPostPictureURLToPostsData(photoURL: String, postID: String, completion: @escaping ((Bool) -> ())) {
        let documentData: [String: Any] = [
            "photoURL": photoURL
        ]
        
        updatePostData(postID: postID, documentData: documentData) { success in
            if success {
                print("Successfully added new picture URL \(photoURL) to post's \(postID) data in database.")
            } else {
                print("Error adding new picture URL to post's \(postID) data in database.")
            }
            completion(success)
        }
    }
    
    func deletePostPictureURLFromPostsData(postID: String, completion: @escaping ((Bool) -> ())) {
        let documentData: [String: String?] = [
            "photoURL": nil
        ]
        
        updatePostData(postID: postID, documentData: documentData) { success in
            if success {
                print("Successfully removed picture URL from post's \(postID) data in database.")
            } else {
                print("Error removing picture URL from post's \(postID) data in database.")
            }
            completion(success)
        }
    }
    
    func postRemoval(id: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("posts").document(id).delete() { (error) in
            if let error = error {
                print("Error deleting post: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Successfully deleted post: \(id)")
                completion(true)
            }
        }
    }
    
    func postEdit(id: String, text: String, photoURL: String? = nil, completion: @escaping ((Bool) -> ())) {
        let documentData: [String: Any]
        
        if photoURL == nil {
            documentData = [
                "text": text
            ]
        } else {
            documentData = [
                "text": text,
                "photoURL": photoURL
            ]
        }
        
        updatePostData(postID: id, documentData: documentData) { success in
            if success {
                print("Successfully edited post's \(id) data.")
            } else {
                print("Error editing post's \(id) data.")
            }
            completion(true)
        }
    }
    
    func postAddReaction(postID: String, userIDThatReacted: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("posts").document(postID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for post add reaction: \(error.localizedDescription)")
                completion(false)
            } else {
                if let document = document {
                    let reactionsUsersIDs = document.get("reactionsUsersIDs") as? [String]? ?? nil
                    if let reactionsUsersIDs = reactionsUsersIDs {
                        if !reactionsUsersIDs.contains(userIDThatReacted) {
                            var newReactionsUsersIDs = reactionsUsersIDs
                            newReactionsUsersIDs.append(userIDThatReacted)
                            
                            let documentData: [String: Any] = [
                                "reactionsUsersIDs": newReactionsUsersIDs
                            ]
                            updatePostData(postID: postID, documentData: documentData) { success in
                                if success {
                                    print("Successfully added reaction of \(userIDThatReacted) to post \(postID)")
                                } else {
                                    print("Error adding reaction of \(userIDThatReacted) to post \(postID)")
                                }
                                completion(success)
                            }
                        } else {
                            print("Reaction of user \(userIDThatReacted) could not be added to post's \(postID) reactions because this user has already reacted to this post before")
                            completion(false)
                        }
                    } else {
                        let newReactionsUsersIDs = [userIDThatReacted]
                        
                        let documentData: [String: Any] = [
                            "reactionsUsersIDs": newReactionsUsersIDs
                        ]
                        updatePostData(postID: postID, documentData: documentData) { success in
                            if success {
                                print("Successfully added reaction of \(userIDThatReacted) to post \(postID)")
                            } else {
                                print("Error adding reaction of \(userIDThatReacted) to post \(postID)")
                            }
                            completion(success)
                        }
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func postRemoveReaction(postID: String, userIDThatRemovedReaction: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("posts").document(postID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for post remove reaction: \(error.localizedDescription)")
                completion(false)
            } else {
                if let document = document {
                    let reactionsUsersIDs = document.get("reactionsUsersIDs") as? [String]? ?? nil
                    if let reactionsUsersIDs = reactionsUsersIDs {
                        if reactionsUsersIDs.contains(userIDThatRemovedReaction) {
                            var newReactionsUsersIDs = [String]()
                            
                            for reactionUserID in reactionsUsersIDs {
                                if reactionUserID != userIDThatRemovedReaction {
                                    newReactionsUsersIDs.append(reactionUserID)
                                }
                            }
                            
                            let documentData: [String: Any] = [
                                "reactionsUsersIDs": newReactionsUsersIDs
                            ]
                            updatePostData(postID: postID, documentData: documentData) { success in
                                if success {
                                    print("Successfully removed reaction of \(userIDThatRemovedReaction) to post \(postID)")
                                } else {
                                    print("Error removing reaction of \(userIDThatRemovedReaction) to post \(postID)")
                                }
                                completion(success)
                            }
                        } else {
                            print("Reaction of user \(userIDThatRemovedReaction) could not be removed from post's \(postID) reactions because this user hasn't reacted to this post before")
                            completion(false)
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
    
    func postAddCommentingUserID(postID: String, userIDThatCommented: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("posts").document(postID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for adding user's id to post's commenting users: \(error.localizedDescription)")
                completion(false)
            } else {
                if let document = document {
                    let commentedUsersIDs = document.get("commentedUsersIDs") as? [String]? ?? nil
                    if let commentedUsersIDs = commentedUsersIDs {
                        if !commentedUsersIDs.contains(userIDThatCommented) {
                            var newCommentedUsersIDs = commentedUsersIDs
                            newCommentedUsersIDs.append(userIDThatCommented)
                            
                            let documentData: [String: Any] = [
                                "commentedUsersIDs": newCommentedUsersIDs
                            ]
                            updatePostData(postID: postID, documentData: documentData) { success in
                                if success {
                                    print("Successfully added user \(userIDThatCommented) to post's \(postID) commented users ids")
                                } else {
                                    print("Error adding user \(userIDThatCommented) to post's \(postID) commented users ids")
                                }
                                completion(success)
                            }
                        } else {
                            print("Comment of user \(userIDThatCommented) could not be added to post's \(postID) commented users ids because this user has already commented post before")
                            completion(false)
                        }
                    } else {
                        let newCommentedUsersIDs = [userIDThatCommented]
                        
                        let documentData: [String: Any] = [
                            "commentedUsersIDs": newCommentedUsersIDs
                        ]
                        updatePostData(postID: postID, documentData: documentData) { success in
                            if success {
                                print("Successfully added user \(userIDThatCommented) to post's \(postID) commented users ids")
                            } else {
                                print("Error adding user \(userIDThatCommented) to post's \(postID) commented users ids")
                            }
                            completion(success)
                        }
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func postRemoveCommentingUserID(postID: String, userIDThatRemovedComment: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("posts").document(postID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for removing user's id from post's commenting users: \(error.localizedDescription)")
                completion(false)
            } else {
                if let document = document {
                    let commentedUsersIDs = document.get("commentedUsersIDs") as? [String]? ?? nil
                    
                    if let commentedUsersIDs = commentedUsersIDs {
                        if commentedUsersIDs.contains(userIDThatRemovedComment) {
                            var newCommentedUsersIDs = [String]()
                            
                            for commentedUserID in commentedUsersIDs {
                                if commentedUserID != userIDThatRemovedComment {
                                    newCommentedUsersIDs.append(commentedUserID)
                                }
                            }
                            
                            let documentData: [String: Any] = [
                                "commentedUsersIDs": newCommentedUsersIDs
                            ]
                            updatePostData(postID: postID, documentData: documentData) { success in
                                if success {
                                    print("Successfully removed user \(userIDThatRemovedComment) from post's \(postID) commented users ids")
                                } else {
                                    print("Error removing user \(userIDThatRemovedComment) from post's \(postID) commented users ids")
                                }
                                completion(success)
                            }
                        } else {
                            print("User \(userIDThatRemovedComment) could not be removed from post's \(postID) commented users ids because this user hasn't commented this post before")
                            completion(false)
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
    
    func postChangeAuthorProfilePictureURL(authorID: String, authorProfilePictureURL: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("posts").whereField("authorID", isEqualTo: authorID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents in posts collection for profilePictureURL change: \(error.localizedDescription)")
                completion(false)
            } else {
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        let data = document.data()
                        let documentID = data["id"] as? String ?? ""
                        
                        let documentData: [String: Any] = [
                            "authorProfilePictureURL": authorProfilePictureURL
                        ]
                        self.updatePostData(postID: documentID, documentData: documentData) { success in
                            if success {
                                print("Successfully added user's \(authorID) new profile picture url to post's \(documentID) data")
                            } else {
                                print("Error adding user's \(authorID) new profile picture url to post's \(documentID) data")
                            }
                            completion(success)
                        }
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    
    
    // Comments
    
    func fetchComments(postID: String, completion: @escaping (([Comment]?, Bool) -> ())) {
        var fetchedComments: [Comment] = [Comment]()

        self.db.collection("comments").whereField("postID", isEqualTo: postID).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error fetching comments data: \(error.localizedDescription)")
                completion(nil, false)
            } else {
                fetchedComments = querySnapshot!.documents.map { (queryDocumentSnapshot) -> Comment in
                    let data = queryDocumentSnapshot.data()

                    let id = data["id"] as? String ?? ""
                    let authorID = data["authorID"] as? String ?? ""
                    let postID = data["postID"] as? String ?? ""
                    let authorFirstName = data["authorFirstName"] as? String ?? ""
                    let authorUsername = data["authorUsername"] as? String ?? ""
                    let authorProfilePictureURL = data["authorProfilePictureURL"] as? String ?? ""
                    let addDate = data["addDate"] as? Timestamp
                    let text = data["text"] as? String ?? ""
                    let reactionsUsersIDs = data["reactionsUsersIDs"] as? [String]? ?? nil

                    return Comment(id: id, authorID: authorID, postID: postID, authorFirstName: authorFirstName, authorUsername: authorUsername, authorProfilePictureURL: authorProfilePictureURL, addDate: (addDate?.dateValue())!, text: text, reactionsUsersIDs: reactionsUsersIDs)
                }
                
                DispatchQueue.main.async {
                    if fetchedComments.count != 0 {
                        fetchedComments.sort() {
                            $0.addDate > $1.addDate
                        }
                        completion(fetchedComments, true)
                    } else {
                        completion(nil, false)
                    }
                }
            }
        }
    }
    
    func commentDataCreation(id: String, authorID: String, postID: String, authorFirstName: String, authorUsername: String, authorProfilePictureURL: String, addDate: Date, text: String, reactionsUsersIDs: [String]?, completion: @escaping ((Bool) -> ())) {
        let documentData: [String: Any] = [
            "id": id,
            "authorID": authorID,
            "postID": postID,
            "authorFirstName": authorFirstName,
            "authorUsername": authorUsername,
            "authorProfilePictureURL": authorProfilePictureURL,
            "addDate": Date(),
            "text": text,
            "reactionsUsersIDs": reactionsUsersIDs as Any
        ]
        
        self.db.collection("comments").document(id).setData(documentData) { (error) in
            if let error = error {
                print("Error creating comment's data: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Successfully created comment: \(id) by user: \(authorID)")
                completion(true)
            }
        }
    }
    
    func commentRemoval(id: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("comments").document(id).delete() { (error) in
            if let error = error {
                print("Error deleting post: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Successfully deleted comment: \(id)")
                completion(true)
            }
        }
    }
    
    func commentEdit(id: String, text: String, completion: @escaping ((Bool) -> ())) {
        let documentData: [String: Any] = [
            "text": text
        ]
        updateCommentData(commentID: id, documentData: documentData) { success in
            if success {
                print("Successfully editing comment \(id) data.")
                completion(true)
            } else {
                print("Error editing comment \(id) data.")
                completion(false)
            }
            
        }
    }
    
    func commentAddReaction(commentID: String, userIDThatReacted: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("comments").document(commentID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for comment add reaction: \(error.localizedDescription)")
                completion(false)
            } else {
                if let document = document {
                    let reactionsUsersIDs = document.get("reactionsUsersIDs") as? [String]? ?? nil
                    if let reactionsUsersIDs = reactionsUsersIDs {
                        if !reactionsUsersIDs.contains(userIDThatReacted) {
                            var newReactionsUsersIDs = reactionsUsersIDs
                            newReactionsUsersIDs.append(userIDThatReacted)
                            
                            let documentData: [String: Any] = [
                                "reactionsUsersIDs": newReactionsUsersIDs
                            ]
                            updateCommentData(commentID: commentID, documentData: documentData) { success in
                                if success {
                                    print("Successfully added reaction of \(userIDThatReacted) to comment \(commentID)")
                                } else {
                                    print("Error adding reaction of \(userIDThatReacted) to comment \(commentID)")
                                }
                                completion(success)
                            }
                        } else {
                            print("Reaction of user \(userIDThatReacted) could not be added to comment's \(commentID) reactions because this user has already reacted to this comment before")
                            completion(false)
                        }
                    } else {
                        let newReactionsUsersIDs = [userIDThatReacted]
                        
                        let documentData: [String: Any] = [
                            "reactionsUsersIDs": newReactionsUsersIDs
                        ]
                        updateCommentData(commentID: commentID, documentData: documentData) { success in
                            if success {
                                print("Successfully added reaction of \(userIDThatReacted) to comment \(commentID)")
                            } else {
                                print("Error adding reaction of \(userIDThatReacted) to comment \(commentID)")
                            }
                            completion(success)
                        }
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func commentRemoveReaction(commentID: String, userIDThatRemovedReaction: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("comments").document(commentID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for comment remove reaction: \(error.localizedDescription)")
                completion(false)
            } else {
                if let document = document {
                    let reactionsUsersIDs = document.get("reactionsUsersIDs") as? [String]? ?? nil
                    if let reactionsUsersIDs = reactionsUsersIDs {
                        if reactionsUsersIDs.contains(userIDThatRemovedReaction) {
                            var newReactionsUsersIDs = [String]()
                            
                            for reactionUserID in reactionsUsersIDs {
                                if reactionUserID != userIDThatRemovedReaction {
                                    newReactionsUsersIDs.append(reactionUserID)
                                }
                            }
                            
                            let documentData: [String: Any] = [
                                "reactionsUsersIDs": newReactionsUsersIDs
                            ]
                            updateCommentData(commentID: commentID, documentData: documentData) { success in
                                if success {
                                    print("Successfully removed reaction of \(userIDThatRemovedReaction) to comment \(commentID)")
                                } else {
                                    print("Error removing reaction of \(userIDThatRemovedReaction) to comment \(commentID)")
                                }
                                completion(success)
                            }
                        } else {
                            print("Reaction of user \(userIDThatRemovedReaction) could not be removed from comment's \(commentID) reactions because this user hasn't reacted to this comment before")
                            completion(false)
                        }
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func checkForMultipleCommentsOfSameUserToSamePost(postID: String, userID: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("comments").whereField("authorID", isEqualTo: userID).whereField("postID", isEqualTo: postID).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents for checking for multiple comments of same user to same post: \(error.localizedDescription)")
                completion(false)
            } else {
                if let querySnapshot = querySnapshot {
                    if querySnapshot.documents.count != 0 {
                        print("The user \(userID) has added \(querySnapshot.documents.count) comments to the post \(postID).")
                        completion(true)
                    } else {
                        print("The user \(userID) has not added any comments to the post \(postID)")
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func commentChangeAuthorProfilePictureURL(authorID: String, authorProfilePictureURL: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("comments").whereField("authorID", isEqualTo: authorID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents in comments collection for profilePictureURL change: \(error.localizedDescription)")
                completion(false)
            } else {
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        let data = document.data()
                        let documentID = data["id"] as? String ?? ""
                        
                        let documentData: [String: Any] = [
                            "authorProfilePictureURL": authorProfilePictureURL
                        ]
                        self.updateCommentData(commentID: documentID, documentData: documentData) { success in
                            if success {
                                print("Successfully added user's \(authorID) new profile picture url to comment's \(documentID) data")
                            } else {
                                print("Error adding user's \(authorID) new profile picture url to comment's \(documentID) data")
                            }
                            completion(success)
                        }
                    }
                } else {
                    completion(false)
                }
            }
        }
            
    }
    
    
    //Workouts
    
    func fetchWorkouts(userID: String, completion: @escaping (([IntervalWorkout]?, Bool) -> ())) {
        var fetchedWorkouts: [IntervalWorkout] = [IntervalWorkout]()

        self.db.collection("workouts").whereField("usersID", isEqualTo: userID).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error fetching workouts data: \(error.localizedDescription)")
                completion(nil, false)
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
                        completion(fetchedWorkouts, true)
                    } else {
                        completion(nil, false)
                    }
                }
            }
        }
    }
    
    func workoutDataCreation(id: String, usersID: String, type: String, date: Date, isFinished: Bool, calories: Int?, series: Int?, workTime: Int?, restTime: Int?, completedDuration: Int?, completedSeries: Int?, completion: @escaping ((Bool) -> ())) {
        let documentData: [String: Any] = [
            "id": id,
            "usersID": usersID,
            "type": type,
            "date": date,
            "isFinished": isFinished,
            "calories": calories as Any,
            "series": series as Any,
            "workTime": workTime as Any,
            "restTime": restTime as Any,
            "completedDuration": completedDuration as Any,
            "completedSeries": completedSeries as Any,
        ]
        
        self.db.collection("workouts").document(id).setData(documentData) { (error) in
            if let error = error {
                print("Error creating workout's data: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Successfully created data for workout: \(id) finished by user: \(usersID)")
                
                self.addCompletedWorkout(userID: usersID) { success in
                    completion(success)
                }
            }
        }
    }
    
    
    
    // Universal
    
    func getAllUsersIDs(userID: String, completion: @escaping (([String]?, Bool) -> ())) {
        self.db.collection("users").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents in 'users' collection: \(error.localizedDescription)")
                completion(nil, false)
            } else {
                var usersIDs = [String]()
                
                for document in querySnapshot!.documents {
                    let data = document.data()

                    let newUserID = data["id"] as? String ?? ""
                    if newUserID != userID {
                        usersIDs.append(newUserID)
                    }
                }
                
                completion(usersIDs, true)
            }
        }
    }
    
    func getAllUsersData(userID: String, completion: @escaping (([String]?, Bool) -> ())) {
        self.db.collection("users").document(userID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user data for getting users firstName and username: \(error.localizedDescription)")
                completion(nil, false)
            } else {
                if let document = document {
                    let firstName = document.get("firstName") as? String ?? ""
                    let username = document.get("username") as? String ?? ""
                    let profilePictureURL = document.get("profilePictureURL") as? String ?? ""
                    
                    completion([firstName, username, profilePictureURL], true)
                }
            }
        }
    }
    
    private func updateUserData(documentData: [String: Any], completion: @escaping ((Bool) -> ())) {
        self.db.collection("users").document(user!.uid).updateData(documentData) { (error) in
            if let error = error {
                print("Error updating user's data: \(error.localizedDescription)")
                completion(false)
            }
            completion(true)
        }
    }
    
    private func updatePostData(postID: String, documentData: [String: Any], completion: @escaping ((Bool) -> ())) {
        self.db.collection("posts").document(postID).updateData(documentData) { (error) in
            if let error = error {
                print("Error updating post's data: \(error.localizedDescription)")
                completion(false)
            }
            completion(true)
        }
    }
    
    private func updateCommentData(commentID: String, documentData: [String: Any], completion: @escaping ((Bool) -> ())) {
        self.db.collection("comments").document(commentID).updateData(documentData) { (error) in
            if let error = error {
                print("Error updating comment's data: \(error.localizedDescription)")
                completion(false)
            }
            completion(true)
        }
    }
}
