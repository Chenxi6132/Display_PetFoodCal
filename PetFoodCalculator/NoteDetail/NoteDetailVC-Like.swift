//
//  NoteDetailVC-Like.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 8/15/24.
//

import FirebaseFirestore
import FirebaseAuth

extension NoteDetailVC{
    func like(){
        if let _ = Auth.auth().currentUser{
            //UI
            isLike ? (likeCount += 1) : (likeCount -= 1)
            
            //data
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(likeBtnTappedWhenLogin), object: nil)
            perform(#selector(likeBtnTappedWhenLogin), with: nil, afterDelay: 1)
            
        }else{
            showLoginHUD()
        }
        
    }
    
    
    @objc private func likeBtnTappedWhenLogin() {
        likeStatusChanged?(isLike)
        if likeCount != currentLikeCount{
            let user = Auth.auth().currentUser!
            let noteID = note.getExactStringVal(kNoteID)
            
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
                db.collection(kUserLikeTable)
                    .whereField(kUser, isEqualTo: user.uid)
                    .whereField(kNote, isEqualTo: noteID)
                    .getDocuments { snapshot, error in
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
                
                
                //increment like count in Note table
                let NoteRef = db.collection("Notes").document(noteID)
                NoteRef.updateData([kLikedCount : FieldValue.increment(Int64(-1))])
                
                //increment like count in user table
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
