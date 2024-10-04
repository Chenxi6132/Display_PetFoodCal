//
//  NoteDetailVC-Fave.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 8/15/24.
//

import FirebaseFirestore
import FirebaseAuth

extension NoteDetailVC{
    func fave(){
        if let _ = Auth.auth().currentUser{
            //UI
            isFav ? (favCount += 1) : (favCount -= 1)
            
            //data
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(FavBtnTappedWhenLogin), object: nil)
            perform(#selector(FavBtnTappedWhenLogin), with: nil, afterDelay: 1)
            
        }else{
            showLoginHUD()
        }
    }
    
    @objc private func FavBtnTappedWhenLogin() {
        if favCount != currentFavCount{
            let user = Auth.auth().currentUser!
            let noteID = note.getExactStringVal(kNoteID)
            
            let offset = isFav ? 1 : -1
            currentFavCount += offset
            
            if isFav{
                db.collection(kUserFavTable).document(UUID().uuidString).setData([
                    kUser: user.uid,
                    kNote: noteID
                ])
                
                //increment like count in Note table
                let NoteRef = db.collection("Notes").document(noteID)
                NoteRef.updateData([kFavedCount : FieldValue.increment(Int64(1))])
                
                NoteRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let authorRef = document.get(kAuthor) as? DocumentReference {
                            authorRef.updateData([kFaveCount: FieldValue.increment(Int64(1))])
                        }
                    }
                }
                
            }else{
                db.collection(kUserFavTable)
                    .whereField(kUser, isEqualTo: user.uid)
                    .whereField(kNote, isEqualTo: noteID)
                    .getDocuments { snapshot, error in
                        if let error = error { print("Error getting documents: \(error.localizedDescription)")
                            return }
                        
                        if let document = snapshot?.documents.first {
                            document.reference.delete { error in
                                if let error = error {
                                    print("Error deleting document: \(error.localizedDescription)")
                                } else {
                                    print("Successfully Unfav Note")
                                }
                            }
                        } else {
                            print("Fav Document not found")
                        }
                    }
                
                
                //decrement like count in Note table
                let NoteRef = db.collection("Notes").document(noteID)
                NoteRef.updateData([kFavedCount : FieldValue.increment(Int64(-1))])
                
                //decrement like count in user table
                NoteRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let authorRef = document.get(kAuthor) as? DocumentReference {
                            authorRef.updateData([kFaveCount: FieldValue.increment(Int64(-1))])
                        }
                    }
                }
            }
            
        }
    }
}
