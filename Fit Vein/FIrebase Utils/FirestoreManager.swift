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
            "reactedCommentsIDs": [String]()
        ]
        
        self.db.collection("users").document(id).setData(documentData) { (error) in
            if let error = error {
                print("Error creating user's data: \(error.localizedDescription)")
                completion(nil, false)
            } else {
                print("Successfully created data for user: \(username) identifying with id: \(id) in database")
                completion(Profile(id: id, firstName: firstName, username: username, birthDate: birthDate, age: yearsBetweenDate(startDate: birthDate, endDate: Date()) == 0 ? 18 : yearsBetweenDate(startDate: birthDate, endDate: Date()), country: country, language: language, gender: gender, email: email, profilePictureURL: nil, followedIDs: nil, reactedPostsIDs: nil, commentedPostsIDs: nil), true)
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
    
    func deleteUserData(userID: String, completion: @escaping (() -> ())) {
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
                        self.removeUserFromFollowed(userID: userDocument.documentID, userIDToStopFollow: userID) {
                            print("Successfully removed user's id from users ids followed by user \(userDocument.documentID)")
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
                                                    self.removeCommentIDFromCommentsReactedByUser(userID: userDocument.documentID, commentID: document.documentID) {
                                                        print("Successfully removed comment's id from comments ids reacted by user: \(userDocument.documentID)")
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
                                                    self.removePostIDFromPostsReactedByUser(userID: userDocument.documentID, postID: document.documentID) {
                                                        print("Successfully removed post id from post ids reacted by user: \(userDocument.documentID)")
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
                                                    self.removePostIDFromPostsCommentedByUser(userID: userDocument.documentID, postID: document.documentID) {
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
                                self.commentRemoveReaction(commentID: document.documentID, userIDThatRemovedReaction: userID) {}
                            case "posts":
                                self.postRemoveCommentingUserID(postID: document.documentID, userIDThatRemovedComment: userID) {
                                    self.postRemoveReaction(postID: document.documentID, userIDThatRemovedReaction: userID) {}
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
            self.deleteUserExistence(userID: userID) {
                completion()
            }
        }
    }
    
    private func deleteUserExistence(userID: String, completion: @escaping (() -> ())) {
        self.db.collection("users").document(userID).delete() { (error) in
            if let error = error {
                print("Error deleting user's data: \(error)")
            } else {
                completion()
            }
        }
    }
    
    func addPostIDToPostsReactedByUser(userID: String, postID: String, completion: @escaping (() -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for adding postID to posts reacted by user: \(error.localizedDescription)")
                completion()
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
                            updateUserData(documentData: documentData) {
                                print("Successfully added post \(postID) to posts reacted by user")
                                completion()
                            }
                        } else {
                            print("Post \(postID) was not added to posts reacted by user because it has already been reacted before.")
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func removePostIDFromPostsReactedByUser(userID: String, postID: String, completion: @escaping (() -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for removing postID from posts reacted by user: \(error.localizedDescription)")
                completion()
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
                            updateUserData(documentData: documentData) {
                                print("Successfully removed post \(postID) from posts reacted by user")
                                completion()
                            }
                        } else {
                            print("Post \(postID) was not removed from posts reacted by user becuase it hasn't been reacted before.")
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func addPostIDToPostsCommentedByUser(userID: String, postID: String, completion: @escaping (() -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for adding commented post by user: \(error.localizedDescription)")
                completion()
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
                            updateUserData(documentData: documentData) {
                                print("Successfully added post \(postID) to posts commented by user")
                                completion()
                            }
                        } else {
                            print("Post \(postID) was not added to posts commented by user because it has already been commented before.")
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func removePostIDFromPostsCommentedByUser(userID: String, postID: String, completion: @escaping (() -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for removing commented post by user: \(error.localizedDescription)")
                completion()
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
                            updateUserData(documentData: documentData) {
                                print("Successfully removed post \(postID) from posts commented by user")
                                completion()
                            }
                        } else {
                            print("Post \(postID) was not removed from posts commented by user becuase it hasn't been commented before.")
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func addCommentIDToCommentsReactedByUser(userID: String, commentID: String, completion: @escaping (() -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for adding reacted comment for user: \(error.localizedDescription)")
                completion()
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
                            updateUserData(documentData: documentData) {
                                print("Successfully added comment \(commentID) to comments reacted by user")
                                completion()
                            }
                        } else {
                            print("Comment \(commentID) was not added to comments reacted by user because it has already been reacted before.")
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func removeCommentIDFromCommentsReactedByUser(userID: String, commentID: String, completion: @escaping (() -> ())) {
        self.db.collection("users").document(userID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for removing reacted comment for user: \(error.localizedDescription)")
                completion()
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
                            updateUserData(documentData: documentData) {
                                print("Successfully removed comment \(commentID) from comment reacted by user")
                                completion()
                            }
                        } else {
                            print("Comment \(commentID) was not removed from comments reacted by user becuase it hasn't been reacted before.")
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
                if !fetchedFollowed.contains(userIDToFollow) {
                    var fetchedFollowedToBeModified = fetchedFollowed
                    fetchedFollowedToBeModified.append(userIDToFollow)
                    let documentData: [String: Any] = [
                        "followedUsers": fetchedFollowedToBeModified
                    ]
                    updateUserData(documentData: documentData) {
                        print("Successfully added user \(userIDToFollow) to users followed by the user \(userID)")
                        completion()
                    }
                } else {
                    print("User \(userIDToFollow) was not added to users followed by the user \(userID) because he has already been followed before")
                    completion()
                }
            } else {
                let documentData: [String: Any] = [
                    "followedUsers": [userIDToFollow]
                ]
                updateUserData(documentData: documentData) {
                    print("Successfully added first user \(userIDToFollow) to users followed by the user \(userID)")
                    completion()
                }
            }
        }
    }
    
    func removeUserFromFollowed(userID: String, userIDToStopFollow: String, completion: @escaping (() -> ())) {
        self.fetchFollowed(userID: userID) { [self] fetchedFollowed in
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
                    updateUserData(documentData: documentData) {
                        print("Successfully removed user \(userIDToStopFollow) from user \(userID) followed users")
                        completion()
                    }
                } else {
                    print("User \(userIDToStopFollow) was not removed from users followed by the user \(userID) because he hasn't been followed before")
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
    
    func postAddReaction(postID: String, userIDThatReacted: String, completion: @escaping (() -> ())) {
        self.db.collection("posts").document(postID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for post add reaction: \(error.localizedDescription)")
                completion()
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
                            updatePostData(postID: postID, documentData: documentData) {
                                print("Successfully added reaction of \(userIDThatReacted) to post \(postID)")
                                completion()
                            }
                        } else {
                            print("Reaction of user \(userIDThatReacted) could not be added to post's \(postID) reactions because this user has already reacted to this post before")
                            completion()
                        }
                    } else {
                        let newReactionsUsersIDs = [userIDThatReacted]
                        
                        let documentData: [String: Any] = [
                            "reactionsUsersIDs": newReactionsUsersIDs
                        ]
                        updatePostData(postID: postID, documentData: documentData) {
                            print("Successfully added reaction of \(userIDThatReacted) to post \(postID)")
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func postRemoveReaction(postID: String, userIDThatRemovedReaction: String, completion: @escaping (() -> ())) {
        self.db.collection("posts").document(postID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for post remove reaction: \(error.localizedDescription)")
                completion()
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
                            updatePostData(postID: postID, documentData: documentData) {
                                print("Successfully added reaction of \(userIDThatRemovedReaction) to post \(postID)")
                                completion()
                            }
                        } else {
                            print("Reaction of user \(userIDThatRemovedReaction) could not be removed from post's \(postID) reactions because this user hasn't reacted to this post before")
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func postAddCommentingUserID(postID: String, userIDThatCommented: String, completion: @escaping (() -> ())) {
        self.db.collection("posts").document(postID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for adding user's id to post's commenting users: \(error.localizedDescription)")
                completion()
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
                            updatePostData(postID: postID, documentData: documentData) {
                                print("Successfully added comment of \(userIDThatCommented) to post \(postID)")
                                completion()
                            }
                        } else {
                            print("Comment of user \(userIDThatCommented) could not be added to post's \(postID) commented users ids because this user has already commented post before")
                            completion()
                        }
                    } else {
                        let newCommentedUsersIDs = [userIDThatCommented]
                        
                        let documentData: [String: Any] = [
                            "commentedUsersIDs": newCommentedUsersIDs
                        ]
                        updatePostData(postID: postID, documentData: documentData) {
                            print("Successfully added user \(userIDThatCommented) to post's \(postID) commented users ids")
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func postRemoveCommentingUserID(postID: String, userIDThatRemovedComment: String, completion: @escaping (() -> ())) {
        self.db.collection("posts").document(postID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for removing user's id from post's commenting users: \(error.localizedDescription)")
                completion()
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
                            updatePostData(postID: postID, documentData: documentData) {
                                print("Successfully removed user \(userIDThatRemovedComment) from post's \(postID) commented users ids")
                                completion()
                            }
                        } else {
                            print("User \(userIDThatRemovedComment) could not be removed from post's \(postID) commented users ids because this user hasn't commented this post before")
                            completion()
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
                print("Error creating comment's data: \(error.localizedDescription)")
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
    
    func commentAddReaction(commentID: String, userIDThatReacted: String, completion: @escaping (() -> ())) {
        self.db.collection("comments").document(commentID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for comment add reaction: \(error.localizedDescription)")
                completion()
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
                            updateCommentData(commentID: commentID, documentData: documentData) {
                                print("Successfully added reaction of \(userIDThatReacted) to comment \(commentID)")
                                completion()
                            }
                        } else {
                            print("Reaction of user \(userIDThatReacted) could not be added to comment's \(commentID) reactions because this user has already reacted to this comment before")
                            completion()
                        }
                    } else {
                        let newReactionsUsersIDs = [userIDThatReacted]
                        
                        let documentData: [String: Any] = [
                            "reactionsUsersIDs": newReactionsUsersIDs
                        ]
                        updateCommentData(commentID: commentID, documentData: documentData) {
                            print("Successfully added reaction of \(userIDThatReacted) to comment \(commentID)")
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func commentRemoveReaction(commentID: String, userIDThatRemovedReaction: String, completion: @escaping (() -> ())) {
        self.db.collection("comments").document(commentID).getDocument() { [self] (document, error) in
            if let error = error {
                print("Error getting document for comment remove reaction: \(error.localizedDescription)")
                completion()
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
                            updateCommentData(commentID: commentID, documentData: documentData) {
                                print("Successfully removed reaction of \(userIDThatRemovedReaction) from comment \(commentID)")
                                completion()
                            }
                        } else {
                            print("Reaction of user \(userIDThatRemovedReaction) could not be removed from comment's \(commentID) reactions because this user hasn't reacted to this comment before")
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func checkForMultipleCommentsOfSameUserToSamePost(postID: String, userID: String, completion: @escaping ((Bool) -> ())) {
        self.db.collection("comments").whereField("authorID", isEqualTo: userID).whereField("postID", isEqualTo: postID).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents for checking for multiple comments of same user to same post.")
                completion(false)
            } else {
                if let querySnapshot = querySnapshot {
                    if querySnapshot.documents.count != 0 {
                        completion(true)
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
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
    
    func getAllUsersData(userID: String, completion: @escaping (([String]?) -> ())) {
        self.db.collection("users").document(userID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user data for getting users firstName and username: \(error.localizedDescription)")
            } else {
                if let document = document {
                    let firstName = document.get("firstName") as? String ?? ""
                    let username = document.get("username") as? String ?? ""
                    let profilePictureURL = document.get("profilePictureURL") as? String ?? ""
                    
                    completion([firstName, username, profilePictureURL])
                }
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
