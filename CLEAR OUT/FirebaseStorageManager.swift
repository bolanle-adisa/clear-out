//
//  FirebaseStorageManager.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit
import MobileCoreServices

class FirebaseStorageManager {
    
    static let shared = FirebaseStorageManager()
    
    private init() {} // Private initializer for Singleton
    
    func uploadImageToStorage(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(StorageError.failedToConvertImage))
            return
        }
        
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")
        
        let uploadTask = imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            imageRef.downloadURL { (url, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let downloadURL = url {
                    completion(.success(downloadURL))
                }
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            if let progress = snapshot.progress {
                print("Upload progress: \(progress.fractionCompleted)")
            }
        }
    }
    
    func uploadVideoToStorage(_ videoURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let storageRef = Storage.storage().reference()
        let videoRef = storageRef.child("videos/\(UUID().uuidString).mov")
        
        print("Starting upload...")

        // Ensure you handle the copying of the video file to the app's directory before this point
        // as demonstrated in your provided snippet.
        
        let uploadTask = videoRef.putFile(from: videoURL, metadata: nil) { metadata, error in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            videoRef.downloadURL { (url, error) in
                if let error = error {
                    print("Failed to get download URL: \(error.localizedDescription)")
                    completion(.failure(error))
                } else if let downloadURL = url {
                    print("Upload completed: \(downloadURL)")
                    completion(.success(downloadURL))
                }
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            if let progress = snapshot.progress {
                let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                print("Upload progress: \(percentComplete)%")
            }
        }
    }

    
    enum StorageError: Error {
        case failedToConvertImage
    }
}
