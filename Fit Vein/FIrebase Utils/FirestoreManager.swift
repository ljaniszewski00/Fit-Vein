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
    
    func signUpDataCreation(id: String, firstName: String, username: String, birthDate: Date, country: String, language: String, email: String, gender: String) async {
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
        
        do {
            let error = try await self.db.collection("users").document(id).setData(documentData)
            guard error == nil else {
                throw DatabaseError.createUserDataFailed
            }
            print("Successfully created data for user: \(username) identifying with id: \(id) in database")
        } catch {
            print(error.localizedDescription)
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
            print("FOUND")
            return true
        } else {
            print("NOT FOUND")
            return false
        }
    }
    
    func fetchDataForProfileViewModel(userID: String) async throws -> (String, String, Date, Int, String, String, String, String, String?) {
        let document = try await self.db.collection("users").document(userID).getDocument()
        
        let firstName = document.get("firstName") as? String ?? ""
        let username = document.get("username") as? String ?? ""
        let birthDate = document.get("birthDate") as? Date ?? Date()
        let age = document.get("age") as? Int ?? 0
        let country = document.get("country") as? String ?? ""
        let language = document.get("language") as? String ?? ""
        let gender = document.get("gender") as? String ?? ""
        let email = document.get("email") as? String ?? ""
        let profilePictureURL = document.get("profilePictureURL") as? String ?? nil
        
        return (firstName, username, birthDate, age, country, language, gender, email, profilePictureURL)
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
