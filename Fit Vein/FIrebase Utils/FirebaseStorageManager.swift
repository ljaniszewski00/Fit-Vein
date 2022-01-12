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
    
    func uploadImageToStorage(image: UIImage, userID: String, completion: @escaping ((String?, Bool) -> ())) {
        let imageUUID = UUID().uuidString
        let userImagesStorageRef = storageRef.child("images/\(userID)/\(imageUUID)")
        
        let data = image.jpegData(compressionQuality: 1)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.customMetadata = ["username": userID]
        
        if let data = data {
            userImagesStorageRef.putData(data, metadata: metadata) { _, error in
                if let error = error {
                    print("Error uploading photo: \(error.localizedDescription)")
                    completion(nil, false)
                } else {
                    completion(imageUUID, true)
                }
            }
        } else {
            completion(nil, false)
        }
    }
    
    func deleteImageFromStorage(userPhotoURL: String, userID: String, completion: @escaping ((Bool) -> ())) {
        let userImagesStorageRef = storageRef.child("images/\(userID)/\(userPhotoURL)")

        userImagesStorageRef.delete() { (error) in
            if let error = error {
                print("Error deleting image from storage: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Successfully deleted image from storage")
                completion(true)
            }
        }
    }
    
    func getDownloadURLForImage(stringURL: String, userID: String, completion: @escaping ((URL?, Bool) -> ())) {
        let path = "images/\(userID)/\(stringURL)"
        let userImagesStorageRef = storageRef.child(path)
        userImagesStorageRef.downloadURL() { url, error in
            if let error = error {
                print("Error getting download URL: \(error.localizedDescription)")
                completion(nil, false)
            } else {
                completion(url, true)
            }
        }
    }
    
    func downloadImageFromStorage(userID: String, userPhotoURL: String, completion: @escaping ((UIImage?, Bool) -> ())) {
        let userImagesStorageRef = storageRef.child("images/\(userID)/\(userPhotoURL)")
        
        userImagesStorageRef.getData(maxSize: 1 * 100 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("Error downloading file: ", error.localizedDescription)
                completion(nil, false)
            } else {
                if let data = data {
                    let image = UIImage(data: data)!
                    completion(image, true)
                } else {
                    completion(nil, false)
                }
            }
        }
    }
}
