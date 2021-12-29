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
            "gender": gender,
            "followedIDs": [String](),
            "reactedPostsIDs": [String](),
            "commentedPostsIDs": [String](),
            "reactedCommentsIDs": [String]()
        ]
        
        self.db.collection("users").document(id).setData(documentData) { (error) in
            if let error = error {
                print("Error creating user's data: \(error.localizedDescription)")
            } else {
                print("Successfully created data for user: \(username) identifying with id: \(id) in database")
                completion(Profile(id: id, firstName: firstName, username: username, birthDate: birthDate, age: yearsBetweenDate(startDate: birthDate, endDate: Date()) == 0 ? 18 : yearsBetweenDate(startDate: birthDate, endDate: Date()), country: country,
                                   language: language, gender: gender, email: email, profilePictureURL: nil, followedIDs: nil, reactedPostsIDs: nil, commentedPostsIDs: nil))
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
                    let followedIDs = data["followedUsers"] as? [String]? ?? nil
                    let reactedPostsIDs = data["reactedPostsIDs"] as? [String]? ?? nil
                    let commentedPostsIDs = data["commentedPostsIDs"] as? [String]? ?? nil
                    let reactedCommentsIDs = data["reactedCommentsIDs"] as? [String]? ?? nil

                    return Profile(id: userID, firstName: firstName, username: username, birthDate: birthDate, age: age, country: country, language: language, gender: gender, email: email, profilePictureURL: profilePictureURL, followedIDs: followedIDs, reactedPostsIDs: reactedPostsIDs, commentedPostsIDs: commentedPostsIDs, reactedCommentsIDs: reactedCommentsIDs)
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
        let queue = DispatchQueue(label: "SerialQueue")
        
        queue.async {
            //Firstly, delete the id of user, who is deleting his/her account, from arrays of followed ids of all user who followed this user
            self.db.collection("users").whereField("followedUsers", arrayContains: userUID).getDocuments() { (querySnapshot, error) in
                if let error = error {
                    print("Error getting users for followed users modify upon when user deletes his account: \(error.localizedDescription)")
                } else {
                    for userDocument in querySnapshot!.documents {
                        self.removeUserFromFollowed(userID: userDocument.documentID, userIDToStopFollow: userUID) {
                            print("Successfully removed user's id from users ids followed by user \(userDocument.documentID)")
                        }
                    }
                }
            }
            
            //Secondly, delete all activity made by user - his comments, his workouts and his posts, including the reactions
            for collection in ["comments", "workouts", "posts"] {
                self.db.collection(collection).whereField(["comments", "posts"].contains(collection) ? "authorID" : "usersID", isEqualTo: userUID).getDocuments() { (querySnapshot, error) in
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
                                        // Delete reaction to previously deleted comment
                                        self.db.collection("users").whereField("reactedCommentsIDs", arrayContains: document.documentID).getDocuments() { (querySnapshot, error) in
                                            if let error = error {
                                                print("Error getting users for reacted comments modify upon comment removal when user deletes his account: \(error.localizedDescription)")
                                            } else {
                                                for userDocument in querySnapshot!.documents {
                                                    self.removeReactedCommentID(userID: userDocument.documentID, commentID: document.documentID) {
                                                        print("Successfully removed comment's id from comments ids reacted by user: \(userDocument.documentID)")
                                                    }
                                                }
                                            }
                                        }
                                    case "posts":
                                        // Delete reaction to previously deleted post
                                        self.db.collection("users").whereField("reactedPostsIDs", arrayContains: document.documentID).getDocuments() { (querySnapshot, error) in
                                            if let error = error {
                                                print("Error getting users for reacted posts modify upon comment removal when user deletes his account: \(error.localizedDescription)")
                                            } else {
                                                for userDocument in querySnapshot!.documents {
                                                    self.removeReactedPostID(userID: userDocument.documentID, postID: document.documentID) {
                                                        print("Successfully removed post id from post ids reacted by user: \(userDocument.documentID)")
                                                    }
                                                }
                                            }
                                        }
                                        
                                        // Delete comment to previously deleted post
                                        self.db.collection("users").whereField("commentedPostsIDs", arrayContains: document.documentID).getDocuments() { (querySnapshot, error) in
                                            if let error = error {
                                                print("Error getting users for commented posts modify upon comment removal when user deletes his account: \(error.localizedDescription)")
                                            } else {
                                                for userDocument in querySnapshot!.documents {
                                                    self.removeCommentedPostID(userID: userDocument.documentID, postID: document.documentID) {
                                                        print("Successfully removed post id from post ids commented by user: \(userDocument.documentID)")
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
            }
        }
        
        queue.async {
            //Finally, delete user from 'users' collection
            self.deleteUserExistence(userUID: userUID) {
                completion()
            }
        }
    }
    
    private func deleteUserExistence(userUID: String, completion: @escaping (() -> ())) {
        self.db.collection("users").document(userUID).delete() { (error) in
            if let error = error {
                print("Error deleting user's data: \(error)")
            } else {
                completion()
            }
        }
    }
    
    func addReactedPostID(userID: String, postID: String, completion: @escaping (() -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for adding reacted post for user: \(error.localizedDescription)")
            } else {
                if let document = document {
                    let reactedPostsIDs = document.get("reactedPostsIDs") as? [String]? ?? nil
                    
                    if let reactedPostsIDs = reactedPostsIDs {
                        var newReactionsPostsIDs = reactedPostsIDs
                        newReactionsPostsIDs.append(postID)
                        
                        let documentData: [String: Any] = [
                            "reactedPostsIDs": newReactionsPostsIDs
                        ]
                        updateUserData(documentData: documentData) {
                            print("Successfully added post \(postID) to user reacted")
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func removeReactedPostID(userID: String, postID: String, completion: @escaping (() -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for removing reacted post for user: \(error.localizedDescription)")
            } else {
                if let document = document {
                    let reactedPostsIDs = document.get("reactedPostsIDs") as? [String]? ?? nil
                    
                    if let reactedPostsIDs = reactedPostsIDs {
                        var newReactionsPostsIDs = reactedPostsIDs
                        for (index, reactionsPostID) in newReactionsPostsIDs.enumerated() {
                            if reactionsPostID == postID {
                                newReactionsPostsIDs.remove(at: index)
                            }
                        }
                        
                        let documentData: [String: Any] = [
                            "reactedPostsIDs": newReactionsPostsIDs
                        ]
                        updateUserData(documentData: documentData) {
                            print("Successfully removed post \(postID) from user reacted")
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func addCommentedPostID(userID: String, postID: String, completion: @escaping (() -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for adding commented post for user: \(error.localizedDescription)")
            } else {
                if let document = document {
                    let commentedPostsIDs = document.get("commentedPostsIDs") as? [String]? ?? nil
                    
                    if let commentedPostsIDs = commentedPostsIDs {
                        var newCommentedPostsIDs = commentedPostsIDs
                        newCommentedPostsIDs.append(postID)
                        
                        let documentData: [String: Any] = [
                            "commentedPostsIDs": newCommentedPostsIDs
                        ]
                        updateUserData(documentData: documentData) {
                            print("Successfully added post \(postID) to user commented")
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func removeCommentedPostID(userID: String, postID: String, completion: @escaping (() -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for removing commented post for user: \(error.localizedDescription)")
            } else {
                if let document = document {
                    let commentedPostsIDs = document.get("commentedPostsIDs") as? [String]? ?? nil
                    
                    if let commentedPostsIDs = commentedPostsIDs {
                        var newCommentedPostsIDs = commentedPostsIDs
                        for (index, commentedPostID) in newCommentedPostsIDs.enumerated() {
                            if commentedPostID == postID {
                                newCommentedPostsIDs.remove(at: index)
                            }
                        }
                        
                        let documentData: [String: Any] = [
                            "commentedPostsIDs": newCommentedPostsIDs
                        ]
                        updateUserData(documentData: documentData) {
                            print("Successfully removed post \(postID) from user commented")
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func addReactedCommentID(userID: String, commentID: String, completion: @escaping (() -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for adding reacted comment for user: \(error.localizedDescription)")
            } else {
                if let document = document {
                    let reactedCommentsIDs = document.get("reactedCommentsIDs") as? [String]? ?? nil
                    
                    if let reactedCommentsIDs = reactedCommentsIDs {
                        var newReactedCommentsIDs = reactedCommentsIDs
                        newReactedCommentsIDs.append(commentID)
                        
                        let documentData: [String: Any] = [
                            "commentedPostsIDs": newReactedCommentsIDs
                        ]
                        updateUserData(documentData: documentData) {
                            print("Successfully added comment \(commentID) to user reacted")
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func removeReactedCommentID(userID: String, commentID: String, completion: @escaping (() -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for removing reacted comment for user: \(error.localizedDescription)")
            } else {
                if let document = document {
                    let reactedCommentsIDs = document.get("reactedCommentsIDs") as? [String]? ?? nil
                    
                    if let reactedCommentsIDs = reactedCommentsIDs {
                        var newReactedCommentsIDs = reactedCommentsIDs
                        for (index, reactedCommentID) in newReactedCommentsIDs.enumerated() {
                            if reactedCommentID == commentID {
                                newReactedCommentsIDs.remove(at: index)
                            }
                        }
                        
                        let documentData: [String: Any] = [
                            "commentedPostsIDs": newReactedCommentsIDs
                        ]
                        updateUserData(documentData: documentData) {
                            print("Successfully removed comment \(commentID) from user reacted")
                            completion()
                        }
                    }
                }
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
                var fetchedFollowedToBeModified = fetchedFollowed
                fetchedFollowedToBeModified.append(userIDToFollow)
                let documentData: [String: Any] = [
                    "followedUsers": fetchedFollowedToBeModified
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
                        let reactionsUsersIDs = data["reactionsUsersIDs"] as? [String]? ?? nil
                        let commentedUsersIDs = data["commentedUsersIDs"] as? [String]? ?? nil

                        return Post(id: id, authorID: authorID, authorFirstName: authorFirstName, authorUsername: authorUsername, authorProfilePictureURL: authorProfilePictureURL, addDate: (addDate?.dateValue())!, text: text, reactionsUsersIDs: reactionsUsersIDs, commentedUsersIDs: commentedUsersIDs, comments: nil)
                    }
                    
                    DispatchQueue.main.async {
                        if fetchedPosts.count != 0 {
                            fetchedPosts.sort() {
                                $0.addDate > $1.addDate
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
    
    func postDataCreation(id: String, authorID: String, authorFirstName: String, authorUsername: String, authorProfilePictureURL: String, addDate: Date, text: String, reactionsUsersIDs: [String]?, comments: [Comment]?, completion: @escaping (() -> ())) {
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
            "comments": comments as Any
        ]
        
        self.db.collection("posts").document(id).setData(documentData) { (error) in
            if let error = error {
                print("Error creating post's data: \(error.localizedDescription)")
            } else {
                print("Successfully created post: \(id) by user: \(authorID)")
            }
            completion()
        }
    }
    
    func postRemoval(id: String, completion: @escaping (() -> ())) {
        self.db.collection("posts").document(id).delete() { (error) in
            if let error = error {
                print("Error deleting post: \(error.localizedDescription)")
            } else {
                print("Successfully deleted post: \(id)")
            }
            completion()
        }
    }
    
    func postEdit(id: String, text: String, completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "text": text
        ]
        updatePostData(postID: id, documentData: documentData) {
            print("Successfully changed post \(id) data.")
            completion()
        }
    }
    
    func postAddReaction(id: String, userID: String, completion: @escaping (() -> ())) {
        var removedReaction = false
        
        self.db.collection("posts").document(id).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for post add reaction: \(error.localizedDescription)")
            } else {
                if let document = document {
                    let reactionsUsersIDs = document.get("reactionsUsersIDs") as? [String]? ?? nil
                    
                    if let reactionsUsersIDs = reactionsUsersIDs {
                        var newReactionsUsersIDs = reactionsUsersIDs
                        if newReactionsUsersIDs.contains(userID) {
                            for (index, userID) in newReactionsUsersIDs.enumerated() {
                                if userID == userID {
                                    newReactionsUsersIDs.remove(at: index)
                                    removedReaction = true
                                    break
                                }
                            }
                        } else {
                            newReactionsUsersIDs.append(userID)
                        }
                        
                        let documentData: [String: Any] = [
                            "reactionsUsersIDs": newReactionsUsersIDs
                        ]
                        updatePostData(postID: id, documentData: documentData) {
                            print("Successfully added reaction of \(userID) to post \(id)")
                            completion()
                        }
                    } else {
                        let newReactionsUsersIDs = [userID]
                        
                        let documentData: [String: Any] = [
                            "reactionsUsersIDs": newReactionsUsersIDs
                        ]
                        updatePostData(postID: id, documentData: documentData) {
                            print(!removedReaction ? "Successfully added reaction of \(userID) to post \(id)" : "Successfully removed reaction of \(userID) to post \(id)")
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func postAddCommentingUserID(id: String, userID: String, completion: @escaping (() -> ())) {
        self.db.collection("posts").document(id).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for adding commenting user id for post: \(error.localizedDescription)")
            } else {
                if let document = document {
                    let commentedUsersIDs = document.get("commentedUsersIDs") as? [String]? ?? nil
                    
                    if let commentedUsersIDs = commentedUsersIDs {
                        if !commentedUsersIDs.contains(userID) {
                            var newCommentedUsersIDs = commentedUsersIDs
                            newCommentedUsersIDs.append(userID)
                            
                            let documentData: [String: Any] = [
                                "commentedUsersIDs": newCommentedUsersIDs
                            ]
                            updatePostData(postID: id, documentData: documentData) {
                                print("Successfully added user \(userID) to users ids that commented post")
                                completion()
                            }
                        }
                    } else {
                        let newCommentedUsersIDs = [userID]
                        
                        let documentData: [String: Any] = [
                            "commentedUsersIDs": newCommentedUsersIDs
                        ]
                        updatePostData(postID: id, documentData: documentData) {
                            print("Successfully added user \(userID) to users ids that commented post")
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func postRemoveCommentingUserID(id: String, userID: String, completion: @escaping (() -> ())) {
        self.db.collection("posts").document(id).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for removing commenting user id for post: \(error.localizedDescription)")
            } else {
                if let document = document {
                    let commentedUsersIDs = document.get("commentedUsersIDs") as? [String]? ?? nil
                    
                    if let commentedUsersIDs = commentedUsersIDs {
                        if commentedUsersIDs.contains(userID) {
                            var newCommentedUsersIDs = commentedUsersIDs
                            for (index, commentedUserID) in newCommentedUsersIDs.enumerated() {
                                if commentedUserID == userID {
                                    newCommentedUsersIDs.remove(at: index)
                                }
                            }
                            
                            let documentData: [String: Any] = [
                                "commentedUsersIDs": newCommentedUsersIDs
                            ]
                            updatePostData(postID: id, documentData: documentData) {
                                print("Successfully removed user \(userID) from users ids that commented post")
                                completion()
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    // Comments
    
    func fetchComments(postID: String, completion: @escaping (([Comment]?) -> ())) {
        var fetchedComments: [Comment] = [Comment]()

        self.db.collection("comments").whereField("postID", isEqualTo: postID).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error fetching comments data: \(error.localizedDescription)")
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
                        completion(fetchedComments)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func commentDataCreation(id: String, authorID: String, postID: String, authorFirstName: String, authorUsername: String, authorProfilePictureURL: String, addDate: Date, text: String, reactionsUsersIDs: [String]?, completion: @escaping (() -> ())) {
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
                print("Error creating post's data: \(error.localizedDescription)")
            } else {
                print("Successfully created comment: \(id) by user: \(authorID)")
            }
            completion()
        }
    }
    
    func commentRemoval(id: String, completion: @escaping (() -> ())) {
        self.db.collection("comments").document(id).delete() { (error) in
            if let error = error {
                print("Error deleting post: \(error.localizedDescription)")
            } else {
                print("Successfully deleted comment: \(id)")
            }
            completion()
        }
    }
    
    func commentEdit(id: String, text: String, completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "text": text
        ]
        updateCommentData(commentID: id, documentData: documentData) {
            print("Successfully changed comment \(id) data.")
            completion()
        }
    }
    
    func commentAddReaction(id: String, userID: String, completion: @escaping (() -> ())) {
        var removedReaction = false
        
        self.db.collection("comments").document(id).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for comment add reaction: \(error.localizedDescription)")
            } else {
                if let document = document {
                    let reactionsUsersIDs = document.get("reactionsUsersIDs") as? [String]? ?? nil
                    
                    if let reactionsUsersIDs = reactionsUsersIDs {
                        var newReactionsUsersIDs = reactionsUsersIDs
                        if newReactionsUsersIDs.contains(userID) {
                            for (index, userID) in newReactionsUsersIDs.enumerated() {
                                if userID == userID {
                                    newReactionsUsersIDs.remove(at: index)
                                    removedReaction = true
                                    break
                                }
                            }
                        } else {
                            newReactionsUsersIDs.append(userID)
                        }
                        
                        let documentData: [String: Any] = [
                            "reactionsUsersIDs": newReactionsUsersIDs
                        ]
                        updateCommentData(commentID: id, documentData: documentData) {
                            print("Successfully added reaction of \(userID) to comment \(id)")
                            completion()
                        }
                    } else {
                        let newReactionsUsersIDs = [userID]
                        
                        let documentData: [String: Any] = [
                            "reactionsUsersIDs": newReactionsUsersIDs
                        ]
                        updateCommentData(commentID: id, documentData: documentData) {
                            print(!removedReaction ? "Successfully added reaction of \(userID) to comment \(id)" : "Successfully removed reaction of \(userID) to comment \(id)")
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    
    
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
            } else {
                print("Successfully created data for workout: \(id) finished by user: \(usersID)")
            }
            completion()
        }
    }
    
    
    
    // Universal
    
    func getAllUsersIDs(userID: String, completion: @escaping (([String]?) -> ())) {
        self.db.collection("users").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents in 'users' collection: \(error.localizedDescription)")
            } else {
                var usersIDs = [String]()
                
                for document in querySnapshot!.documents {
                    let data = document.data()

                    let newUserID = data["id"] as? String ?? ""
                    if newUserID != userID {
                        usersIDs.append(newUserID)
                    }
                }
                
                completion(usersIDs)
            }
        }
    }
    
    private func updateUserData(documentData: [String: Any], completion: @escaping (() -> ())) {
        self.db.collection("users").document(user!.uid).updateData(documentData) { (error) in
            if let error = error {
                print("Error updating user's data: \(error.localizedDescription)")
            }
            completion()
        }
    }
    
    private func updatePostData(postID: String, documentData: [String: Any], completion: @escaping (() -> ())) {
        self.db.collection("posts").document(postID).updateData(documentData) { (error) in
            if let error = error {
                print("Error updating post's data: \(error.localizedDescription)")
            }
            completion()
        }
    }
    
    private func updateCommentData(commentID: String, documentData: [String: Any], completion: @escaping (() -> ())) {
        self.db.collection("comments").document(commentID).updateData(documentData) { (error) in
            if let error = error {
                print("Error updating comment's data: \(error.localizedDescription)")
            }
            completion()
        }
    }
}
