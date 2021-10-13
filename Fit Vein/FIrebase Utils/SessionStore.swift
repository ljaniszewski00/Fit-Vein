//
//  SessionStore.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 12/10/2021.
//

import Foundation
import Firebase

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
    private let authRef = Auth.auth()
    public let currentUser = Auth.auth().currentUser
    
    func listen() {
        handle = authRef.addStateDidChangeListener({ (auth, user) in
            if let user = user {
                self.session = User(uid: user.uid, email: user.email!)
            } else {
                self.session = nil
            }
        })
    }
    
    func signIn(email: String, password: String) async {
        do {
            let authResult = try await authRef.signIn(withEmail: email, password: password)
            guard authResult != nil else {
                throw AuthError.authFailed
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func signUp(email: String, password: String) async -> String {
        do {
            let authResult = try await authRef.createUser(withEmail: email, password: password)
            guard authResult != nil else {
                throw AuthError.authFailed
            }
            return authResult.user.uid
        } catch {
            print(error.localizedDescription)
        }
        return ""
    }
    
    func signOut() {
        do {
            self.session = nil
            try authRef.signOut()
        } catch {
        }
    }
    
    func unbind () {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
    
//    @Published var session: User?
//    @Published var isAnonymous = true
//    
//    var handle: AuthStateDidChangeListenerHandle?
//    private let authRef = Auth.auth()
//    public let currentUser = Auth.auth().currentUser
//    
//    func listen() async throws {
//        handle = authRef.addStateDidChangeListener({ (auth, user) in
//            if let user = user {
//                self.isAnonymous = false
//                self.session = User(uid: user.uid, email: user.email!)
//            } else {
//                self.isAnonymous = true
//                self.session = nil
//            }
//        })
//    }
//    
//    func signIn(email: String, password: String, completion: @escaping (() -> ())) {
//        authRef.signIn(withEmail: email, password: password) { (result, error) in
//            if let error = error {
//                print("Error signing in: \(error.localizedDescription)")
//            } else {
//                completion()
//            }
//        }
//    }
//    
//    
//    func signOut() {
//        do {
//            self.session = nil
//            self.isAnonymous = true
//            try authRef.signOut()
//        } catch {
//        }
//    }
//    
//    func sendRecoveryEmail(_ email: String, completion: @escaping (() -> ())) {
//        authRef.sendPasswordReset(withEmail: email) { (error) in
//            if let error = error {
//                print("Error sending recovery e-mail: \(error.localizedDescription)")
//            } else {
//                completion()
//            }
//        }
//    }
//    
//    func changeEmailAddress(oldEmailAddress: String, password: String, newEmailAddress: String, completion: @escaping (() -> ())) {
//        let credential = EmailAuthProvider.credential(withEmail: oldEmailAddress, password: password)
//        
//        currentUser?.reauthenticate(with: credential) { [self] (result, error) in
//            if let error = error {
//                print("Error re-authenticating user \(error)")
//            } else {
//                self.firestoreManager.editUserEmailInDatabase(email: newEmailAddress) {
//                    print("Successfully updated user's email address")
//                }
//                
//                currentUser?.updateEmail(to: newEmailAddress) { (error) in
//                    if let error = error {
//                        print("Error changing email address: \(error.localizedDescription)")
//                    } else {
//                        completion()
//                    }
//                }
//            }
//        }
//    }
//    
//    func changePassword(emailAddress: String, oldPassword: String, newPassword: String, completion: @escaping (() -> ())) {
//        let credential = EmailAuthProvider.credential(withEmail: emailAddress, password: oldPassword)
//        
//        currentUser?.reauthenticate(with: credential) { [self] (result, error) in
//            if let error = error {
//                print("Error re-authenticating user \(error)")
//            } else {
//                currentUser?.updatePassword(to: newPassword) { (error) in
//                    if let error = error {
//                        print("Error changing password: \(error.localizedDescription)")
//                    } else {
//                        completion()
//                    }
//                }
//            }
//        }
//    }
//    
//    func deleteUser(email: String, password: String, completion: @escaping (() -> ())) {
//        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
//        
//        currentUser?.reauthenticate(with: credential) { [self] (result, error) in
//            if let error = error {
//                print("Error re-authenticating user \(error)")
//            } else {
//                currentUser?.delete { (error) in
//                    if let error = error {
//                        print("Could not delete user: \(error)")
//                    } else {
//                        self.signOut()
//                        completion()
//                    }
//                }
//            }
//        }
//    }
