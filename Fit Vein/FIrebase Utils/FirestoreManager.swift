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
    
    func signUpDataCreation(id: String, firstName: String, username: String, birthDate: Date, country: String, city: String, language: String, email: String, gender: String) async {
        let documentData: [String: Any] = [
            "id": id,
            "firstName": firstName,
            "username": username,
            "birthDate": birthDate,
            "age": yearsBetweenDate(startDate: birthDate, endDate: Date()) == 0 ? 18 : yearsBetweenDate(startDate: birthDate, endDate: Date()),
            "country": country,
            "city": city,
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
    
    func fetchDataForProfileViewModel(userID: String) async throws -> (String, String, Date, Int, String, String, String, String, String, URL?) {
        let document = try await self.db.collection("users").document(userID).getDocument()
        
        let firstName = document.get("firstName") as? String ?? ""
        let username = document.get("lastName") as? String ?? ""
        let birthDate = document.get("birthDate") as? Date ?? Date()
        let age = document.get("age") as? Int ?? 0
        let country = document.get("country") as? String ?? ""
        let city = document.get("city") as? String ?? ""
        let language = document.get("language") as? String ?? ""
        let gender = document.get("gender") as? String ?? ""
        let email = document.get("email") as? String ?? ""
        let profilePictureURL = document.get("profilePictureURL") as? URL ?? nil
        
        return (firstName, username, birthDate, age, country, city, language, gender, email, profilePictureURL)
    }
    
    func addProfilePictureToUsersData(photoURL: URL) async throws {
        let documentData: [String: Any] = [
            "profilePicture": photoURL
        ]
        
        try await updateUserData(documentData: documentData)
    }
    
    private func updateUserData(documentData: [String: Any]) async throws {
        do {
            try await self.db.collection("users").document(user!.uid).updateData(documentData)
        } catch {
            print(error.localizedDescription)
        }
    }
}
