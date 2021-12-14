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
    @Published var postsAuthorsProfilePicturesURLs = [String: URL]()
    
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
        
        
    }
    
    init() {
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
                    if self.posts != nil {
                        for post in self.posts! {
                            self.firebaseStorageManager.getDownloadURLForImage(stringURL: post.authorProfilePictureURL, userID: post.authorID) { photoURL in
                                postsAuthorsProfilePicturesURLs.updateValue(value: photoURL, forKey: post.id)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addPost(authorID: String, authorFirstName: String, authorUsername: String, authorProfilePictureURL: String, text: String) {
        self.firestoreManager.postDataCreation(id: UUID().uuidString, authorID: authorID, authorFirstName: authorFirstName, authorUsername: authorUsername, authorProfilePictureURL: authorProfilePictureURL, addDate: Date(), text: text, reactionsNumber: 0, commentsNumber: 0, comments: nil) {
            self.fetchData()
        }
    }
    
    func editPost(postID: String, text: String) {
        
    }
    
    func likePost(postID: String) {
        
    }
    
    func commentPost(postID: String, authorID: String, authorFirstName: String, authorLastName: String, text: String) {
        
    }
    
    func deletePost(postID: String) {
        self.firestoreManager.postRemoval(id: postID) {}
    }
    
    func getPostAuthorProfilePictureURL(authorID: String, stringPhotoURL: String, completion: @escaping ((URL?) -> ())) {
        self.firebaseStorageManager.getDownloadURLForImage(stringURL: stringPhotoURL, userID: authorID) { photoURL in
            completion(photoURL)
        }
    }
}
