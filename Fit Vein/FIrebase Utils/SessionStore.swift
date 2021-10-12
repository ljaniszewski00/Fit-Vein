//
//  SessionStore.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 12/10/2021.
//

import Foundation
import Firebase

class SessionStore: ObservableObject {
    let auth = Auth.auth()
    
    @Published var signedIn = false
    
    var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                self?.signedIn = true
            }
        }
    }
    
    func signUp(email: String, password: String) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                self?.signedIn = true
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
//    func signUp(firstName: String, lastName: String, birthDate: Date, country: String, city: String, language: String, email: String, password: String, preference: String, gender: String, completion: @escaping (() -> ())) {
//        authRef.createUser(withEmail: email, password: password) { (result, error) in
//            if let error = error {
//                print("Error signing up: \(error.localizedDescription)")
//            } else {
////                self.firestoreManager.signUpDataCreation(id: result!.user.uid, firstName: firstName, lastName: lastName, birthDate: birthDate, country: country, city: city, language: language, email: email, preference: preference, gender: gender) {
//                    print("Successfully created user's data in database")
////                    self.firestoreManager.conversationDataCreation(usersUIDs: [String](), messages: [String]()) {
////                        completion()
////                    }
//                }
//            }
//        }
//    }
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
//    
//    func unbind() {
//        if let handle = handle {
//            authRef.removeStateDidChangeListener(handle)
//        }
//    }
}
