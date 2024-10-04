//  UserManger.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/13/24.
import Foundation
import FirebaseFirestore
import GoogleSignIn
import FirebaseAuth
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    
    public func getCurrentUserID() -> String? {return Auth.auth().currentUser?.uid}
    
    public func createProfile(user: User) async throws {
        
        let randomNickName = "Paw-\(String.randomString(6))"
        let randomAvatar = UIImage(named: "avatarPH\(Int.random(in: 1...4))")!
        
        // Convert UIImage to Data
        guard let imageData = randomAvatar.jpegData(compressionQuality: 0.4) else {
            throw NSError(domain: "imageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        let storageRef = storage.reference(forURL: "gs://petfoodcalculator.appspot.com")
        let avatarRef = storageRef.child("ProfilePhoto") .child("\(user.uid)")
        
        
        // Upload image data to Firebase Storage
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let downloadURL: URL = try await withCheckedThrowingContinuation { continuation in
            avatarRef.putData(imageData, metadata: metadata) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                avatarRef.downloadURL { url, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let url = url {
                        continuation.resume(returning: url)
                    }
                }
            }
        }
        
        
        let userData: [String: Any] = [
            kUID: user.uid,
            kDate: Date(),
            kPhoneNumber: user.phoneNumber ?? "",
            kEmail: user.email ?? "",
            kNickName: randomNickName,
            kAvatar: downloadURL.absoluteString,
            kLikeCount: 0,
            kFaveCount: 0
        ]
        
        try await db.collection("Users").document(user.uid).setData(userData)
    }
    
    public func uploadNote(title: String, text: String, coverPhoto: UIImage, photos: [UIImage], videoURL: URL?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = getCurrentUserID() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let noteID = UUID().uuidString
        let coverPhotoRef = storage.reference().child("notes/\(userID)/\(noteID)/coverPhoto.jpg")
        let photosRefs = photos.enumerated().map { index in storage.reference().child("notes/\(userID)/\(noteID)/photo\(index).jpg")}
        let videoRef = videoURL != nil ? storage.reference().child("notes/\(userID)/\(noteID)/video.mp4") : nil
        
        let uploadGroup = DispatchGroup()
        
        var coverPhotoURL: String?
        var photosURLs: [String] = Array(repeating: "", count: photos.count)
        var videoDownloadURL: String?
        
        // Storage metadata for images and video
        let imageMetadata = StorageMetadata()
        imageMetadata.contentType = "image/jpeg"
        
        let videoMetadata = StorageMetadata()
        videoMetadata.contentType = "video/mov"
        
        // Upload cover photo
        uploadGroup.enter()
        if let coverPhotoData = coverPhoto.jpegData(compressionQuality: 0.8) {
            coverPhotoRef.putData(coverPhotoData, metadata: imageMetadata) { metadata, error in
                if let error = error {
                    completion(.failure(error))
                    uploadGroup.leave()
                    return
                }
                coverPhotoRef.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        coverPhotoURL = url?.absoluteString
                    }
                    uploadGroup.leave()
                }
            }
        }
        
        // Upload photos
        for (index, photo) in photos.enumerated() {
            uploadGroup.enter()
            if let photoData = photo.jpegData(compressionQuality: 0.8) {
                photosRefs[index].putData(photoData, metadata: imageMetadata) { metadata, error in
                    if let error = error {
                        completion(.failure(error))
                        uploadGroup.leave()
                        return
                    }
                    photosRefs[index].downloadURL { url, error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            if let url = url?.absoluteString {
                                photosURLs[index] = url
                            }
                        }
                        uploadGroup.leave()
                    }
                }
            }
        }
        
        // Upload video
        if let videoURL = videoURL {
            uploadGroup.enter()
            videoRef?.putFile(from: videoURL, metadata: videoMetadata) { metadata, error in
                if let error = error {
                    completion(.failure(error))
                    uploadGroup.leave()
                    return
                }
                videoRef?.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        videoDownloadURL = url?.absoluteString
                    }
                    uploadGroup.leave()
                }
            }
        }
        
        uploadGroup.notify(queue: .main) {
            guard let coverPhotoURL = coverPhotoURL else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload cover photo"])))
                return
            }
            
            let coverPhotoSize = photos[0].size
            let coverphotoRatio = Double(coverPhotoSize.height / coverPhotoSize.width)
            
            // Fetch user data from "users" collection
            self.db.collection("Users").document(userID).getDocument { document, error in
                if let document = document, document.exists {
                    // Create a reference to the user's document
                    let userRef = self.db.collection("Users").document(userID)
                    
                    // Prepare note data with a reference to the user document under "authorRef"
                    let noteData: [String: Any] = [
                        kUID: userID,
                        kDate: Date(),
                        kNoteID: noteID,
                        kTitle: title,
                        kText: text,
                        kCoverPhoto: coverPhotoURL,
                        kCoverPhotoRatio: coverphotoRatio,
                        kPhotos: photosURLs,
                        kVideo: videoDownloadURL ?? "",
                        kLikedCount: 0,
                        kFavedCount: 0,
                        kCommentCount: 0,
                        kAuthor: userRef // Reference to the user document
                    ]
                    
                    // Save note data to the "Notes" collection
                    self.db.collection("Notes").document(noteID).setData(noteData) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch user data"])))
                }
            }
        }
        
        
        
    }
    
    
    public func updateNote(_ note: DocumentSnapshot, title: String, text: String, coverPhoto: UIImage, photos: [UIImage], videoURL: URL?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = getCurrentUserID() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let noteID = note.getExactStringVal(kNoteID)
        let noteFolderRef = storage.reference().child("notes/\(userID)/\(noteID)")
        
        // Delete existing files in the note's storage folder
        noteFolderRef.listAll { (result, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let deleteGroup = DispatchGroup()
            
            for item in result!.items {
                deleteGroup.enter()
                item.delete { error in
                    if let error = error {
                        completion(.failure(error))
                        deleteGroup.leave()
                        return
                    }
                    deleteGroup.leave()
                }
            }
        }
        
        let coverPhotoRef = storage.reference().child("notes/\(userID)/\(noteID)/coverPhoto.jpg")
        let photosRefs = photos.enumerated().map { index in storage.reference().child("notes/\(userID)/\(noteID)/photo\(index).jpg")}
        let videoRef = videoURL != nil ? storage.reference().child("notes/\(userID)/\(noteID)/video.mp4") : nil
        
        let uploadGroup = DispatchGroup()
        
        var coverPhotoURL: String?
        var photosURLs: [String] = Array(repeating: "", count: photos.count)
        var videoDownloadURL: String?
        
        // Storage metadata for images and video
        let imageMetadata = StorageMetadata()
        imageMetadata.contentType = "image/jpeg"
        
        let videoMetadata = StorageMetadata()
        videoMetadata.contentType = "video/mov"
        
        // Upload cover photo
        uploadGroup.enter()
        if let coverPhotoData = coverPhoto.jpegData(compressionQuality: 0.8) {
            coverPhotoRef.putData(coverPhotoData, metadata: imageMetadata) { metadata, error in
                if let error = error {
                    completion(.failure(error))
                    uploadGroup.leave()
                    return
                }
                coverPhotoRef.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        coverPhotoURL = url?.absoluteString
                    }
                    uploadGroup.leave()
                }
            }
        }
        
        // Upload photos
        for (index, photo) in photos.enumerated() {
            uploadGroup.enter()
            if let photoData = photo.jpegData(compressionQuality: 0.8) {
                photosRefs[index].putData(photoData, metadata: imageMetadata) { metadata, error in
                    if let error = error {
                        completion(.failure(error))
                        uploadGroup.leave()
                        return
                    }
                    photosRefs[index].downloadURL { url, error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            if let url = url?.absoluteString {
                                photosURLs[index] = url
                            }
                        }
                        uploadGroup.leave()
                    }
                }
            }
        }
        
        // Upload video
        if let videoURL = videoURL {
            uploadGroup.enter()
            videoRef?.putFile(from: videoURL, metadata: videoMetadata) { metadata, error in
                if let error = error {
                    completion(.failure(error))
                    uploadGroup.leave()
                    return
                }
                videoRef?.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        videoDownloadURL = url?.absoluteString
                    }
                    uploadGroup.leave()
                }
            }
        }
        
        uploadGroup.notify(queue: .main) {
            guard let coverPhotoURL = coverPhotoURL else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload cover photo"])))
                return
            }
            
            let coverPhotoSize = photos[0].size
            let coverphotoRatio = Double(coverPhotoSize.height / coverPhotoSize.width)
            
            // Prepare note data with a reference to the user document under "authorRef"
            let updatenoteData: [String: Any] = [
                kDate: Date(),
                kTitle: title,
                kText: text,
                kCoverPhoto: coverPhotoURL,
                kCoverPhotoRatio: coverphotoRatio,
                kPhotos: photosURLs,
                kVideo: videoDownloadURL ?? ""
            ]
            
            // Save note data to the "Notes" collection
            self.db.collection("Notes").document(noteID).updateData(updatenoteData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
            
            
        }
        
    }
    
    public func deleteStorageFolder(_ noteID: String, _ userID: String) {
        let folderRef = storage.reference().child("notes/\(userID)/\(noteID)")

        // List all items in the folder
        folderRef.listAll { (result, error) in
            if let error = error {
                print("Error listing items in folder: \(error.localizedDescription)")
                return
            }

            let deleteGroup = DispatchGroup()

            // Delete each item in the folder
            for item in result!.items {
                deleteGroup.enter()
                item.delete { error in
                    if let error = error {
                        print("Failed to delete item \(item.fullPath): \(error.localizedDescription)")
                    } else {
                        print("Successfully deleted item \(item.fullPath)")
                    }
                    deleteGroup.leave()
                }
            }

            // Notify when all items are deleted
            deleteGroup.notify(queue: .main) {
                print("Successfully deleted all items in the folder")
            }
        }
    }

}


