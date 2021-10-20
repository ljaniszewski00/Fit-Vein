//
//  FirebaseStorageManager.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 13/10/2021.
//

import Foundation
import Firebase

@MainActor
class FirebaseStorageManager: ObservableObject {
    private let storageRef = Storage.storage().reference()
    
    func uploadImageToStorage(image: UIImage, userID: String) async throws -> URL? {
        let imageUUID = UUID().uuidString
        let imageURL: URL?
        let userImagesStorageRef = storageRef.child("images/\(userID)/\(imageUUID)")
        
        let data = image.jpegData(compressionQuality: 1)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.customMetadata = ["username": userID]
        
        if let data = data {
            let metadata = userImagesStorageRef.putData(data, metadata: metadata)
            print(metadata)
            imageURL = try await getDownloadURLForImage(userPhotoURL: imageUUID, userID: userID)
            print("Co zwracam: \(imageURL!)")
            return imageURL!
        }
        return nil
    }
    
    func deleteImageFromStorage(userPhotoURL: String, userID: String) async throws {
        let userImagesStorageRef = storageRef.child("images/\(userID)/\(userPhotoURL)")
        
        do {
            try await userImagesStorageRef.delete()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getDownloadURLForImage(userPhotoURL: String, userID: String) async throws -> URL {
        print("Probuje pobrac pelna ze skroconej: \(userPhotoURL)")
        let userImagesStorageRef = storageRef.child("images/\(userID)/\(userPhotoURL)")
        
        return try await userImagesStorageRef.downloadURL()
    }
}
