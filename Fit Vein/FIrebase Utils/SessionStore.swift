//
//  SessionStore.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 12/10/2021.
//

import Foundation
import Firebase
import Combine

struct User {
    var uid: String
    var email: String
}

@MainActor
class SessionStore: ObservableObject {
    
    @Published var session: User?
    private var firestoreManager = FirestoreManager()
    private var firebaseStorageManager = FirebaseStorageManager()
    
    var handle: AuthStateDidChangeListenerHandle?
    private var authRef = Auth.auth()
    public var currentUser = Auth.auth().currentUser
    
    init(forPreviews: Bool) {
        if forPreviews {
            self.session = User(uid: "uid", email: "email")
        }
    }
    
    func listen() {
        handle = authRef.addStateDidChangeListener({ (auth, user) in
            if let user = user {
                self.session = User(uid: user.uid, email: user.email!)
                self.authRef = Auth.auth()
                self.currentUser = Auth.auth().currentUser
            } else {
                self.session = nil
            }
        })
    }
    
    func signIn(email: String, password: String, completion: @escaping ((Bool) -> ())) {
        authRef.signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Successfully signed in")
                completion(true)
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping ((String?, Bool) -> ())) {
        authRef.createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Error signing up: \(error.localizedDescription)")
                completion(nil, false)
            } else {
                print("Successfully signed up")
                completion(result!.user.uid, true)
            }
        }
    }
    
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            self.session = nil
            unbind()
            return true
        } catch {
        }
        return false
    }
    
    func unbind () {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
//    deinit {
//        Task {
//            await unbind()
//        }
//    }
    
    func sendRecoveryEmail(email: String, completion: @escaping ((Bool) -> ())) {
        authRef.sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                print("Error sending recovery email: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Recovery email has been sent")
                completion(true)
            }
        }
    }
    
    func changeEmailAddress(userID: String, oldEmailAddress: String, password: String, newEmailAddress: String, completion: @escaping ((Bool) -> ())) {
        let credential = EmailAuthProvider.credential(withEmail: oldEmailAddress, password: password)
        
        currentUser?.reauthenticate(with: credential) { [self] (result, error) in
            if let error = error {
                print("Error re-authenticating user \(error)")
                completion(false)
            } else {
                currentUser?.updateEmail(to: newEmailAddress) { (error) in
                    if let error = error {
                        print("Error changing email address: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
        }
    }
    
    func changePassword(emailAddress: String, oldPassword: String, newPassword: String, completion: @escaping ((Bool) -> ())) {
        let credential = EmailAuthProvider.credential(withEmail: emailAddress, password: oldPassword)
        
        currentUser?.reauthenticate(with: credential) { [self] (result, error) in
            if let error = error {
                print("Error re-authenticating user \(error)")
                completion(false)
            } else {
                currentUser?.updatePassword(to: newPassword) { (error) in
                    if let error = error {
                        print("Error changing password: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Successfully changed password")
                        completion(true)
                    }
                }
            }
        }
    }
    
    func deleteUser(email: String, password: String, completion: @escaping ((Bool) -> ())) {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        currentUser?.reauthenticate(with: credential) { [self] (result, error) in
            if let error = error {
                print("Error re-authenticating user \(error)")
                completion(false)
            } else {
                currentUser?.delete { (error) in
                    if let error = error {
                        print("Could not delete user: \(error)")
                        completion(false)
                    } else {
                        let result = self.signOut()
                        completion(result)
                    }
                }
            }
        }
    }
}
