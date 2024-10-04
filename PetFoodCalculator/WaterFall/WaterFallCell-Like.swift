//
//  WaterFallCell-Like.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 8/16/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

extension WaterFallCell{
    @objc func likeBtnTappedWhenLogin() {
        if likeCount != currentLikeCount{
            guard let note = note else {return}
            let noteID = note.getExactStringVal(kNoteID)
            let user = Auth.auth().currentUser!
            
            let offset = isLike ? 1 : -1
            currentLikeCount += offset
            
            if isLike{
                db.collection(kUserLikeTable).document(UUID().uuidString).setData([
                    kUser: user.uid,
                    kNote: noteID
                ])
                
                //increment like count in Note table
                let NoteRef = db.collection("Notes").document(noteID)
                NoteRef.updateData([kLikedCount : FieldValue.increment(Int64(1))])
                
                NoteRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let authorRef = document.get(kAuthor) as? DocumentReference {
                            authorRef.updateData([kLikeCount: FieldValue.increment(Int64(1))])
                        }
                    }
                }
                
            }else{
                
                let query = db.collection(kUserLikeTable)
                query.whereField(kUser, isEqualTo: user.uid)
                query.whereField(kNote, isEqualTo: noteID)
                
                query.getDocuments { snapshot, error in
                    if let error = error {
                        print("Error getting documents: \(error.localizedDescription)")
                        return
                    }
                    
                    if let document = snapshot?.documents.first {
                        document.reference.delete { error in
                            if let error = error {
                                print("Error deleting document: \(error.localizedDescription)")
                            } else {
                                print("Successfully Unlike Note")
                            }
                        }
                    } else {
                        print("Like Document not found")
                    }
                }
                
                
                //decrement like count in Note table
                let NoteRef = db.collection("Notes").document(noteID)
                NoteRef.updateData([kLikedCount : FieldValue.increment(Int64(-1))])
                
                //decrement like count in user table
                NoteRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let authorRef = document.get(kAuthor) as? DocumentReference {
                            authorRef.updateData([kLikeCount: FieldValue.increment(Int64(-1))])
                        }
                    }
                }
            }
            
        }
    }
}
