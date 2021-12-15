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
    @Published var postsAuthorsProfilePicturesURLs: [String: URL] = [:]
    
    @Published var fetchingData = true
    
    init(forPreviews: Bool) {

        let commentsPost1: [Comment] = [Comment(authorID: "2", authorFirstName: "Maciej", authorUsername: "maciej23.d", authorProfilePictureURL: "", text: "Excellent :)"), Comment(authorID: "2", authorFirstName: "Maciej", authorUsername: "maciej23.d", authorProfilePictureURL: "", text: "Excellent :)")]

        let commentsPost2: [Comment] = [Comment(authorID: "3", authorFirstName: "Jakub", authorUsername: "jakub23.d", authorProfilePictureURL: "", text: "Excellent :)"), Comment(authorID: "2", authorFirstName: "Maciej", authorUsername: "maciej23.d", authorProfilePictureURL: "", text: "Excellent :)")]

        let commentsPost3: [Comment] = [Comment(authorID: "1", authorFirstName: "Jan", authorUsername: "jan23.d", authorProfilePictureURL: "", text: "Excellent :)"), Comment(authorID: "2", authorFirstName: "Maciej", authorUsername: "maciej23.d", authorProfilePictureURL: "", text: "Excellent :)")]

        self.posts = [Post(id: "1", authorID: "1", authorFirstName: "Jan", authorUsername: "jan23.d", authorProfilePictureURL: "", addDate: Date(), text: "Did this today!", reactionsNumber: 0, commentsNumber: 1, comments: commentsPost1),
                      Post(id: "1", authorID: "2", authorFirstName: "Maciej", authorUsername: "maciej23.d", authorProfilePictureURL: "", addDate: Date(), text: "Good form for now!", reactionsNumber: 0, commentsNumber: 1, comments: commentsPost2),
                      Post(id: "1", authorID: "3", authorFirstName: "Jakub", authorUsername: "jakub23.d", authorProfilePictureURL: "", addDate: Date(), text: " Hell Yeeeah!", reactionsNumber: 0, commentsNumber: 1, comments: commentsPost3)]
        
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
                                postsAuthorsProfilePicturesURLs.updateValue(photoURL, forKey: post.id)
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
