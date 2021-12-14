//
//  HomeViewModel.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    var sessionStore = SessionStore(forPreviews: false)
    private let firestoreManager = FirestoreManager()
    private let firebaseStorageManager = FirebaseStorageManager()
    
    @Published var posts: [Post]?
    
    @Published var fetchingData = true
    
    init(forPreviews: Bool) {
//        let profile1: Profile = Profile(id: "1", firstName: "Jan", username: "jan23.d", birthDate: Date(), age: 18, country: "Poland", language: "Polish", gender: "Male", email: "jan23.d@gmail.com", profilePictureURL: nil)
//        let profile2: Profile = Profile(id: "2", firstName: "Maciej", username: "maciej23.d", birthDate: Date(), age: 18, country: "Poland", language: "Polish", gender: "Male", email: "maciej23.d@gmail.com", profilePictureURL: nil)
//        let profile3: Profile = Profile(id: "3", firstName: "Jakub", username: "jakub23.d", birthDate: Date(), age: 18, country: "Poland", language: "Polish", gender: "Male", email: "jakub23.d@gmail.com", profilePictureURL: nil)
//
//        let commentsPost1: [Comment] = [Comment(author: profile2, text: "Excellent :)"), Comment(author: profile3, text: "Well done!")]
//
//        let commentsPost2: [Comment] = [Comment(author: profile1, text: "Great! Thumbs up."), Comment(author: profile3, text: "Well done!")]
//
//        let commentsPost3: [Comment] = [Comment(author: profile1, text: "Great! Thumbs up."), Comment(author: profile2, text: "Excellent :)")]
//
//        self.posts = [Post(author: profile1, text: "Did this today!", comments: commentsPost1),
//                    Post(author: profile2, text: "Quite a good form for a now.", comments: commentsPost2),
//                    Post(author: profile3, text: "Trying to stay on track.", comments: commentsPost3)]
        
        fetchData()
    }
    
    func setup(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }
    
    func fetchData() {
        if sessionStore != nil {
            if sessionStore.currentUser != nil {
                self.firestoreManager.fetchPosts(userID: self.sessionStore.currentUser!.uid) { [self] fetchedPosts in
                    self.posts = fetchedPosts
                }
            }
        }
    }
    
    func addPost(authorID: String, authorFirstName: String, authorUsername: String, text: String) {
        self.firestoreManager.postDataCreation(id: UUID().uuidString, authorID: authorID, authorFirstName: authorFirstName, authorUsername: authorUsername, addDate: Date(), text: text, reactionsNumber: 0, commentsNumber: 0, comments: nil) {
            self.fetchData()
        }
    }
    
    func editPost(postID: String, text: String) {
        for postIndex in (0..<self.posts!.count) {
            if self.posts![postIndex].id == postID {
                self.posts![postIndex].editPost(newText: text)
                break
            }
        }
    }
    
    func likePost(postID: String) {
        for postIndex in (0..<self.posts!.count) {
            if self.posts![postIndex].id == postID {
                self.posts![postIndex].reactToPost()
                break
            }
        }
    }
    
    func commentPost(postID: String, authorID: String, authorFirstName: String, authorLastName: String, text: String) {
        
    }
    
    func deletePost(postID: String) {
        self.firestoreManager.postRemoval(id: postID) {}
    }
}
