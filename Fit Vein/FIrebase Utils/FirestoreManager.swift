//
//  FirestoreManager.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 13/10/2021.
//

import Foundation
import Firebase
import SwiftUI
import grpc

class FirestoreManager: ObservableObject {
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    func getDatabase() -> Firestore {
        self.db
    }
    
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
            "gender": gender
        ]
        
        self.db.collection("users").document(id).setData(documentData) { (error) in
            if let error = error {
                print("Error creating user's data: \(error.localizedDescription)")
            } else {
                print("Successfully created data for user: \(username) identifying with id: \(id) in database")
                completion(Profile(id: id, firstName: firstName, username: username, birthDate: birthDate, age: yearsBetweenDate(startDate: birthDate, endDate: Date()) == 0 ? 18 : yearsBetweenDate(startDate: birthDate, endDate: Date()), country: country,
                                   language: language, gender: gender, email: email, profilePictureURL: nil))
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
    
    func fetchDataForProfileViewModel(userID: String, completion: @escaping ((Profile) -> ())) {

        self.db.collection("users").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
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

                    return Profile(id: userID, firstName: firstName, username: username, birthDate: birthDate, age: age, country: country, language: language, gender: gender, email: email, profilePictureURL: profilePictureURL)
                }
                
                completion(profile[0])
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
    
    private func updateUserData(documentData: [String: Any], completion: @escaping (() -> ())) {
        self.db.collection("users").document(user!.uid).updateData(documentData) { (error) in
            if let error = error {
                print("Error updating user's data: \(error.localizedDescription)")
            } else {
                completion()
            }
        }
    }
    
    func deleteUserData(userUID: String, completion: @escaping (() -> ())) {
        self.db.collection("users").document(userUID).delete() { (error) in
            if let error = error {
                print("Could not delete user data: \(error)")
            } else {
                completion()
            }
        }
    }
}
