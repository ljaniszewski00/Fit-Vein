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
    @Published var postsComments: [String: [Comment]] = [:]
    
    @Published var usersIDs: [String]?
    
    @Published var fetchingData = true
    
    init(forPreviews: Bool) {

        let commentsPost1: [Comment] = [Comment(authorID: "2", postID: "1", authorFirstName: "Maciej", authorUsername: "maciej23.d", authorProfilePictureURL: "", text: "Excellent :)"), Comment(authorID: "3", postID: "1", authorFirstName: "Maciej", authorUsername: "maciej23.d", authorProfilePictureURL: "", text: "Excellent :)")]

        let commentsPost2: [Comment] = [Comment(authorID: "3", postID: "2", authorFirstName: "Jakub", authorUsername: "jakub23.d", authorProfilePictureURL: "", text: "Excellent :)"), Comment(authorID: "1", postID: "2", authorFirstName: "Maciej", authorUsername: "maciej23.d", authorProfilePictureURL: "", text: "Excellent :)")]

        let commentsPost3: [Comment] = [Comment(authorID: "1", postID: "3", authorFirstName: "Jan", authorUsername: "jan23.d", authorProfilePictureURL: "", text: "Excellent :)"), Comment(authorID: "2", postID: "3", authorFirstName: "Maciej", authorUsername: "maciej23.d", authorProfilePictureURL: "", text: "Excellent :)")]

        self.posts = [Post(id: "1", authorID: "1", authorFirstName: "Jan", authorUsername: "jan23.d", authorProfilePictureURL: "", addDate: Date(), text: "Did this today!", reactionsUsersIDs: nil, commentedUsersIDs: nil, comments: commentsPost1),
                      Post(id: "1", authorID: "2", authorFirstName: "Maciej", authorUsername: "maciej23.d", authorProfilePictureURL: "", addDate: Date(), text: "Good form for now!", reactionsUsersIDs: nil, commentedUsersIDs: nil, comments: commentsPost2),
                      Post(id: "1", authorID: "3", authorFirstName: "Jakub", authorUsername: "jakub23.d", authorProfilePictureURL: "", addDate: Date(), text: " Hell Yeeeah!", reactionsUsersIDs: nil, commentedUsersIDs: nil, comments: commentsPost3)]
        
        self.postsComments = ["1": commentsPost1, "2": commentsPost2, "3": commentsPost3]
        
        self.usersIDs = ["id1", "id2", "id3"]
        
    }
    
    init() {
        fetchData()
    }
    
    func setup(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }
    
    func fetchData() {
        if sessionStore.currentUser != nil {
            self.firestoreManager.fetchPosts(userID: self.sessionStore.currentUser!.uid) { [self] fetchedPosts in
                self.posts = fetchedPosts
                if self.posts != nil {
                    for post in self.posts! {
                        self.firebaseStorageManager.getDownloadURLForImage(stringURL: post.authorProfilePictureURL, userID: post.authorID) { photoURL in
                            postsAuthorsProfilePicturesURLs.updateValue(photoURL, forKey: post.id)
                        }
                        
                        self.firestoreManager.fetchComments(postID: post.id) { comments in
                            if let fetchedComments = comments {
                                postsComments.updateValue(fetchedComments, forKey: post.id)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addPost(authorID: String, authorFirstName: String, authorUsername: String, authorProfilePictureURL: String, text: String) {
        self.firestoreManager.postDataCreation(id: UUID().uuidString, authorID: authorID, authorFirstName: authorFirstName, authorUsername: authorUsername, authorProfilePictureURL: authorProfilePictureURL, addDate: Date(), text: text, reactionsUsersIDs: nil, comments: nil) {
            self.fetchData()
        }
    }
    
    func editPost(postID: String, text: String) {
        if sessionStore.currentUser != nil {
            self.firestoreManager.postEdit(id: postID, text: text) {
                self.fetchData()
            }
        }
    }
    
    func reactToPost(postID: String) {
        if sessionStore.currentUser != nil {
            self.firestoreManager.postAddReaction(id: postID, userID: sessionStore.currentUser!.uid) {
                self.firestoreManager.addReactedPostID(userID: self.sessionStore.currentUser!.uid, postID: postID) {
                    self.fetchData()
                }
            }
        }
    }
    
    func removeReactionFromPost(postID: String) {
        if sessionStore.currentUser != nil {
            self.firestoreManager.removeReactedPostID(userID: self.sessionStore.currentUser!.uid, postID: postID) {
                self.firestoreManager.removeReactedPostID(userID: self.sessionStore.currentUser!.uid, postID: postID) {
                    self.fetchData()
                }
            }
        }
    }
    
    func deletePost(postID: String) {
        self.firestoreManager.postRemoval(id: postID) {
            self.fetchData()
        }
    }
    
    func commentPost(postID: String, authorID: String, authorFirstName: String, authorLastName: String, authorProfilePictureURL: String, text: String) {
        if sessionStore.currentUser != nil {
            self.firestoreManager.commentDataCreation(id: UUID().uuidString, authorID: authorID, postID: postID, authorFirstName: authorFirstName, authorUsername: authorLastName, authorProfilePictureURL: authorProfilePictureURL, addDate: Date(), text: text, reactionsUsersIDs: nil) {
                self.firestoreManager.addCommentedPostID(userID: self.sessionStore.currentUser!.uid, postID: postID) {
                    self.firestoreManager.postAddCommentingUserID(id: postID, userID: authorID) {
                        self.fetchData()
                    }
                }
            }
        }
    }
    
    func editComment(commentID: String, text: String) {
        if sessionStore.currentUser != nil {
            self.firestoreManager.commentEdit(id: commentID, text: text) {
                self.fetchData()
            }
        }
    }
    
    func reactToComment(userID: String, commentID: String) {
        if sessionStore.currentUser != nil {
            self.firestoreManager.commentAddReaction(id: commentID, userID: sessionStore.currentUser!.uid) {
                self.firestoreManager.addReactedCommentID(userID: userID, commentID: commentID) {
                    self.fetchData()
                }
            }
        }
    }
    
    func removeReactionFromComment(userID: String, commentID: String) {
        if sessionStore.currentUser != nil {
            self.firestoreManager.commentAddReaction(id: commentID, userID: sessionStore.currentUser!.uid) {
                self.firestoreManager.removeReactedCommentID(userID: userID, commentID: commentID) {
                    self.fetchData()
                }
            }
        }
    }
    
    func deleteComment(postID: String, commentID: String) {
        if sessionStore.currentUser != nil {
            self.firestoreManager.commentRemoval(id: commentID) {
                self.firestoreManager.removeCommentedPostID(userID: self.sessionStore.currentUser!.uid, postID: postID) {
                    self.firestoreManager.postRemoveCommentingUserID(id: postID, userID: self.sessionStore.currentUser!.uid) {
                        self.fetchData()
                    }
                }
            }
        }
    }
    
    func getPostAuthorProfilePictureURL(authorID: String, stringPhotoURL: String, completion: @escaping ((URL?) -> ())) {
        self.firebaseStorageManager.getDownloadURLForImage(stringURL: stringPhotoURL, userID: authorID) { photoURL in
            completion(photoURL)
        }
    }
    
    func getAllUsersIDs() {
        if sessionStore.currentUser != nil {
            self.firestoreManager.getAllUsersIDs(userID: self.sessionStore.currentUser!.uid) { usersIDs in
                self.usersIDs = usersIDs
            }
        }
    }
}
