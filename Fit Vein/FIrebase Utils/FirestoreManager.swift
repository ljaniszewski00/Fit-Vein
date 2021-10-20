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
}
