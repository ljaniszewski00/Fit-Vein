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
    
    func uploadImageToStorage(image: UIImage, userID: String, completion: @escaping ((String) -> ())) {
        let imageUUID = UUID().uuidString
        let userImagesStorageRef = storageRef.child("images/\(userID)/\(imageUUID)")
        
        let data = image.jpegData(compressionQuality: 1)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.customMetadata = ["username": userID]
        
        if let data = data {
            userImagesStorageRef.putData(data, metadata: metadata) { _, error in
                guard error == nil else {
                    print("Error uploading photo: \(error!.localizedDescription)")
                    return
                }
                completion(imageUUID)
            }
        }
    }
    
    func deleteImageFromStorage(userPhotoURL: String, userID: String, completion: @escaping (() -> ())) {
        let userImagesStorageRef = storageRef.child("images/\(userID)/\(userPhotoURL)")

        userImagesStorageRef.delete() { (error) in
            if let error = error {
                print("Error deleting image from storage: \(error.localizedDescription)")
            } else {
                print("Successfully deleted image from storage")
            }
            completion()
        }
    }
    
    func getDownloadURLForImage(stringURL: String, userID: String, completion: @escaping ((URL) -> ())) {
        let userImagesStorageRef = storageRef.child("images/\(userID)/\(stringURL)")
        userImagesStorageRef.downloadURL() { url, error in
            guard let url = url, error == nil else {
                print("Error getting download URL: \(error!.localizedDescription)")
                return
            }
            
            completion(url)
        }
    }
    
    func downloadImageFromStorage(userID: String, userPhotoURL: String, completion: @escaping ((UIImage) -> ())) {
        let userImagesStorageRef = storageRef.child("images/\(userID)/\(userPhotoURL)")
        
        userImagesStorageRef.getData(maxSize: 1 * 100 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("Error downloading file: ", error.localizedDescription)
            } else {
                if let data = data {
                    let image = UIImage(data: data)!
                    completion(image)
                }
            }
        }
    }
}
